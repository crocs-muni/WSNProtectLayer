/**
 * Implementation of routing component. 
 * 	@version   1.0
 * 	@date      2012-2014
 */

#include "ProtectLayerGlobals.h"
module RouteP{
	uses {
		interface SharedData;
		interface Random;
		interface Dispatcher;
		
		/*************** CTP ****************/
  		interface StdControl as ForwardingControl;
  		interface StdControl as CtpLoggerControl;
  		interface Init as RoutingInit;
  		interface Init as ForwardingInit;
  		interface Init as LinkEstimatorInit;
        
        interface Send as CtpSend;
        interface Receive as CtpReceive;
        interface CollectionPacket;
        interface RootControl; 
        interface CtpInfo;
        interface FixedTopology;
		interface ForwardControl;
		
		interface Timer<TMilli> as CtpSendTimer;
		interface Timer<TMilli> as CtpInitTimer;
		
	}
	provides {
		interface Init as PLInit;
		interface Route;
		}
}
implementation{
	task void initCTP();

	// Logging tag for this component
    static const char *TAG = "RouteP";
	
	//
	//	Init interface
	//
	command error_t PLInit.init() {
		
		// Start CTP initialization.
		post initCTP();
		
		return SUCCESS;
	}
	
	//
	// Route interface
	//
	command node_id_t Route.getParentID(){
#ifndef THIS_IS_BS
		combinedData_t* pData = call SharedData.getAllData();
		if (pData->routePrivData.isValid)
		{
			return pData->routePrivData.parentNodeId;
			
		}
		else
		{
			// Try to find random neighbor, otherwise return INVALID_NODE_ID.
			node_id_t neighbor = INVALID_NODE_ID;
			if (call Route.getRandomNeighborIDB(&neighbor) == SUCCESS)
			{
				return neighbor;
			}	
		}
		
		return INVALID_NODE_ID;
#else
		// Base station case, alternative would be to return own ID, but
		// in order to avoid accidental infinite loops, return invalid ID. 
		return INVALID_NODE_ID;
#endif	// THIS_IS_BS
	}
	
/**
 *  
 *    Is started on init, runs a few seconds (60), sends dummy messages in order to establish valid CTP tree.
 *    Then if parent is still not found, CTP recompute & triggerUpdate is called with message send. If next 60s CTP is turned off (it is possible no valid parent exists).
 */
 
	uint8_t ctp_init_state=CTP_STATE_INIT;
  	uint16_t ctpCurPackets=0;
  	uint16_t ctpBusyCount=0;
  	uint16_t findRootCnt=0;
  	bool parentFound=FALSE;
  	bool ctpBusy=FALSE;
  	bool ctpWorking=FALSE;
  	
  	message_t ctpPkt;
  	nx_struct CtpSendRequestMsg ctpSendRequest;
  	
	task void initCTP(){
		ctp_init_state=CTP_STATE_INIT;
		ctpCurPackets=0;
	  	ctpBusyCount=0;
	  	findRootCnt=0;
	  	ctpBusy=FALSE;
  		ctpWorking=FALSE;
  		parentFound=FALSE;
  	
		// Start forwarding, will be forwarded to
		//  a) Forwarding engine
		//  b) Routing engine
		//  c) Estimator 
		pl_log_d(TAG, "fwdControl.start()\n");
		call ForwardingControl.start();
		
		// Set as a root (on BaseStation)
#ifdef THIS_IS_BS
		pl_log_d(TAG, "setRoot()\n");
		call RootControl.setRoot();
#endif
		
		// One-shot timer only, add some time for CTP tree stabilization at boot
		call CtpInitTimer.startOneShot(CTP_TIME_SEND_AFTER_START + (call Random.rand16() % CTP_TIME_SEND_AFTER_START_RND));
	}
	
    /**
     * Is this quality measure better than the minimum threshold?
     * Implemented assuming quality is EETX 
     */
    bool passLinkEtxThreshold(uint16_t etx) {
        return (etx < ETX_THRESHOLD);
    }	
    
#ifdef CTP_DUMP_NEIGHBORS
	void dumpCtpNeighbors();
#endif
	void dumpNeighbors(){
		combinedData_t* pData = call SharedData.getAllData();
		uint8_t numNeigh = 0;
		uint8_t i=0;
	
		numNeigh = pData->actualNeighborCount;
		pl_log_d(TAG, "neighbors=%u\n", numNeigh);
		
		pl_log_d(TAG, "parent is %u and is %u valid\n", pData->routePrivData.parentNodeId, pData->routePrivData.isValid);
		
		// Iterate over, neighbors, pick only those with quality above threshold.
		for(i=0; i<numNeigh; i++){
			pl_log_d(TAG, "  N[%u] addr=%u\n", i, pData->savedData[i].nodeId);
		}
		
	}
	
	task void stopCTP(){
		pl_log_i(TAG, "CTP term state\n");
		pl_printfflush();
		
		call CtpSendTimer.stop();
		
#ifndef THIS_IS_BS
		{
		combinedData_t* pData = call SharedData.getAllData();
		uint8_t numNeigh = 0;
		uint8_t numAboveThreshold=0;
		
		// In case of Base Station, CTP is kept running.
		// Currently, the whole PL stack is started in one call 
		// (no waiting for button press to transmit magic packet),
		// thus CTP has to be running since network is still not started by magic packet.
		// After BS sends magic packet, nodes will need CTP root to init
		// routing tree. 
		call FixedTopology.setFixedTopology();
		
		// Copy parent and neighbor ids to sharedData.
		if (call CtpInfo.getParent(&(pData->routePrivData.parentNodeId)) != FAIL){ 
		 	pData->routePrivData.isValid=TRUE;
		} else {
			pData->routePrivData.isValid=FALSE;
		}
				
		// Obtain number of neighbors from CTP component.
		numNeigh = call CtpInfo.numNeighbors();
	
		// If zero -> set number of neighbors to zero
		if (numNeigh != 0){
			uint8_t i=0;
		
			// Iterate over, neighbors, pick only those with quality above threshold.
			for(i=0; i<numNeigh && i<MAX_NEIGHBOR_COUNT; i++){
				uint16_t linkQuality = call CtpInfo.getNeighborLinkQuality(i);
				if (passLinkEtxThreshold(linkQuality)){
					pData->savedData[numAboveThreshold].nodeId =  call CtpInfo.getNeighborAddr(i);
					numAboveThreshold++;
				}
			}
			
			pl_log_d(TAG, "stopCTP, %u neigh above thr\n", numAboveThreshold);
			
		}

		//set actual number of neighbors
		pData->actualNeighborCount = numAboveThreshold;
		
		dumpNeighbors();
#ifdef CTP_DUMP_NEIGHBORS
	    dumpCtpNeighbors();
#endif
		pl_log_d(TAG, "##.\n");
		}
#endif // THIS_IS_BS

		// Signalize dispatcher routing is done.
		call Dispatcher.stateFinished(STATE_ROUTES_IN_PROGRESS);
	}

	event void CtpInitTimer.fired(){
		pl_log_d(TAG, "CTPtimerState[%u]\n", ctp_init_state);
		pl_printfflush();
		
		if (ctp_init_state==CTP_STATE_INIT){
			// State = 0 -> start CTP sending timer.
			call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
			// Move to the next state
			ctp_init_state = CTP_STATE_SENDING;
			// Start CTP init timer for CTP stabilizing to fixed topology.
			// Init timer will keep CTP running only some amount of time.
			call CtpInitTimer.startOneShot(CTP_TIME_STOP_AFTER_BOOT);
			
		} else if (ctp_init_state==CTP_STATE_SENDING){
			// Move to the next state -> finish as soon as parent is found.		
			ctp_init_state = CTP_STATE_FIND_PARENT;
			call CtpInitTimer.startOneShot(CTP_TIME_STOP_NO_PARENT);
			call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
			
		} else if(ctp_init_state==CTP_STATE_FIND_PARENT || ctp_init_state==CTP_STATE_TERMINATE){
			// Stopping CTP - moving to fixed topology & stopping CTP sending.
			ctp_init_state=CTP_STATE_TERMINATE;
			post stopCTP();
			
		}
	}

	/**
	 * Task for sending CTP messages.
	 * Used after boot to initialize CTP component - real TCP traffic.
	 */
	void task sendCtpMsg(){
#ifndef THIS_IS_BS	
        error_t sendResult = SUCCESS;
#endif

		// Terminate if CTP is not in use anymore.
		if (ctp_init_state>=CTP_STATE_TERMINATE){
			// CTP ended
			return;
		}
		
		pl_log_d(TAG, "CTPsendTask()\n");

#ifdef THIS_IS_BS
		if (ctp_init_state==CTP_STATE_FIND_PARENT){
			findRootCnt += 1;
			if ((findRootCnt % 5) == 0){
				
				// Trigger updateRouteTask(); and sendBeaconTask() inside CTP 
				pl_log_d(TAG, "CTP update\n");
				call CtpInfo.triggerImmediateRouteUpdate();
				call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
				return;
			}
				
			return;
		}
		
		// If a BS, nothing t
		call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
		
#else	// Only if given node is not a base station.
		//
		// Check if CTP managed to send some packet to the base station.
		if (ctpBusy){
			ctpBusyCount+=1;
			pl_log_w(TAG, "CTPSendTask, busy[%u]\n", ctpBusyCount);
			
			// Start re-tx timer, if aperiodic timer is choosen.
			call CtpSendTimer.startOneShot(CTP_TIME_SEND_FAIL + (call Random.rand16() % CTP_TIME_SEND_FAIL_RND));
			
			// This may also happen if no root is found thus CTP is unable to deliver given message.
			// If no root is found, program will stay in this busy state.
			return;
		}
		
		// If we are trying to find root...
		// Helping CTP by triggering route recomputation (if parent was not found till now, something is wrong).
		if (ctp_init_state==CTP_STATE_FIND_PARENT && parentFound==FALSE){
			// State for finding root, if have one, can stop right now...
			error_t parentStatus=FAIL;
			am_addr_t parent;
			
			parentStatus = call CtpInfo.getParent(&parent);
			if (parentStatus==SUCCESS){
				pl_log_i(TAG, "Parent found: [%u]. CTP End\n", parent);
				ctp_init_state=CTP_STATE_TERMINATE;
				parentFound=TRUE;
				
				// Dump neighbors to the log file
#ifdef CTP_DUMP_NEIGHBORS
				dumpNeighbors();						
#endif				
				return;
			} else {
				pl_log_w(TAG, "Parent NOT found. Err [%u]\n", parentStatus);
				findRootCnt += 1;
				
				// Try to help CTP somehow sometimes...
				if ((findRootCnt % 5) == 0){
					
					// Trigger updateRouteTask(); and sendBeaconTask() inside CTP.
					// New beacon is important here to retransmit current routing state
					// to neighbors and to force others to beacon also.
					pl_log_d(TAG, "CTP route update\n");
					call CtpInfo.triggerImmediateRouteUpdate();
					call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
					return;
					
				} else if ((findRootCnt % 5) == 2) {
					
					// Trigger updateRouteTask() inside CTP, just picks best node/path to the root.
					pl_log_d(TAG, "CTP recompute\n");
					call CtpInfo.recomputeRoutes();
					call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
					return;
				}
			}		
			return;
		}

        sendResult = call CtpSend.send(&ctpPkt, sizeof(CtpResponseMsg));
        if (sendResult == SUCCESS) {
#if PL_LOG_MAX_LEVEL >= 7
			char str[3*sizeof(ctpPkt)];
			unsigned char * pin = (unsigned char *) &ctpPkt;
		    const char * hex = "0123456789ABCDEF";
		    char * pout = str;
		    int i = 0;
		    for(; i < sizeof(CtpResponseMsg)-1; ++i){
		        *pout++ = hex[(*pin>>4)&0xF];
		        *pout++ = hex[(*pin++)&0xF];
		        *pout++ = ':';
		    }
		    *pout++ = hex[(*pin>>4)&0xF];
		    *pout++ = hex[(*pin)&0xF];
		    *pout = 0;
		
			pl_log_s(TAG, "msg=%s;src=%u;dst=%u;len=%u\n", str, TOS_NODE_ID, AM_BROADCAST_ADDR, sizeof(CtpResponseMsg));
			printfflush();
#endif

            ctpBusy=TRUE;
            pl_log_d(TAG, "CTPSendTask\n");
        } else {
        	// log fail
        	pl_log_w(TAG, "CTPSendTask,failed, %u\n", sendResult);
        	
        	// start re-tx timer
			call CtpSendTimer.startOneShot(CTP_TIME_SEND_FAIL + (call Random.rand16() % CTP_TIME_SEND_FAIL_RND));
        }
        
#endif // #ifdef THIS_IS_BS
	}
	
	event void CtpSendTimer.fired(){
		post sendCtpMsg();
	}
	
	event message_t * CtpReceive.receive(message_t *msg, void *payload, uint8_t len){
		return msg;
	}
	
	/**
	 * CTP message was sent. Start timer again according to properties set
	 */
	event void CtpSend.sendDone(message_t *msg, error_t error){
		ctpBusyCount=0;
        ctpBusy = FALSE;
        pl_log_d(TAG, "CTP.sendDone %u\n", error);
        if (ctp_init_state==CTP_STATE_SENDING || ctp_init_state==CTP_STATE_FIND_PARENT){
        	call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
        }
	}
	
	
    
	command error_t Route.getRandomNeighborIDB(node_id_t * neigh){
#ifndef THIS_IS_BS
		combinedData_t* pData = call SharedData.getAllData();	
		if (pData->actualNeighborCount > 0)
		{
			uint8_t chosenOne = 0;
			chosenOne = call Random.rand16() % (pData->actualNeighborCount);
			*neigh = pData->savedData[chosenOne].nodeId;
			pl_log_d(TAG, "random Neighbor %u\n", *neigh);
			return SUCCESS;
		} else
		{
			return FAIL;
		}
		
#endif
		return FAIL;
	}
	
#ifdef CTP_DUMP_NEIGHBORS
	void dumpCtpNeighbors(){
		uint8_t numNeigh = 0;
		uint8_t i=0;
		numNeigh = call CtpInfo.numNeighbors();
		pl_log_d(TAG, "neighbors=%u\n", numNeigh);
		
		// If zero -> nothing to do...
		if (numNeigh == 0){
			return;
		} 
		
		// Iterate over, neighbors, pick only those with quality above threshold.
		for(i=0; i<numNeigh; i++){
			pl_log_d(TAG, "  N[%u] addr=%u etx=%u\n", i, call CtpInfo.getNeighborAddr(i), call CtpInfo.getNeighborLinkQuality(i));
		}
	}
#endif
	
#ifdef THIS_IS_BS
	event void Dispatcher.stateChanged(uint8_t newState) {
		//no code
	}
#endif

}

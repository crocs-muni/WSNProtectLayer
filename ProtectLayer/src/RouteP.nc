/**
 * Implementation of routing component. 
 * 	@version   0.1
 * 	@date      2012-2013
 */

#include "ProtectLayerGlobals.h"
module RouteP{
	uses {
		interface SharedData;
		interface Random;
		interface Dispatcher;
		
#ifdef USE_CTP
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
#endif
		
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
		// TODO: do other initialization
		
                //uint8_t i=0;
		RoutePrivData_t* pTable = call SharedData.getRPrivData();
		
		pTable->isValid = 1;
		/*
		 * Is already done in SharedData
		 * 
		switch (TOS_NODE_ID) {
			case 4: { pTable->parentNodeId = 41; break; }
			case 5: { pTable->parentNodeId = 40; break; }
			case 6: { pTable->parentNodeId = 19; break; }
			case 7: { pTable->parentNodeId = 17; break; }
			case 10: { pTable->parentNodeId = 25; break; }
			case 14: { pTable->parentNodeId = 37; break; }
			case 15: { pTable->parentNodeId = 17; break; }
			case 17: { pTable->parentNodeId = 37; break; }
			case 19: { pTable->parentNodeId = 4; break; }
			case 22: { pTable->parentNodeId = 41; break; }
			case 25: { pTable->parentNodeId = 44; break; }
			case 28: { pTable->parentNodeId = 4; break; }
			case 29: { pTable->parentNodeId = 50; break; }
			case 30: { pTable->parentNodeId = 35; break; }
			case 31: { pTable->parentNodeId = 41; break; }
			case 32: { pTable->parentNodeId = 50; break; }
			case 33: { pTable->parentNodeId = 41; break; }
			case 35: { pTable->parentNodeId = 22; break; }
			case 36: { pTable->parentNodeId = 42; break; }
			case 37: { pTable->parentNodeId = 41; break; }
			case 40: { pTable->parentNodeId = 41; break; }
			case 41: { pTable->parentNodeId = 41; break; }
			case 42: { pTable->parentNodeId = 22; break; }
			case 43: { pTable->parentNodeId = 14; break; }
			case 44: { pTable->parentNodeId = 41; break; }
			case 46: { pTable->parentNodeId = 33; break; }
			case 47: { pTable->parentNodeId = 46; break; }
			case 48: { pTable->parentNodeId = 33; break; }
			case 50: { pTable->parentNodeId = 31; break; }
			default: pTable->isValid = 1;
			} 
		*/
		
		// Start CTP initialization.
		post initCTP();
		
		return SUCCESS;
	}
	
	//
	// Route interface
	//
	command node_id_t Route.getParentID(){
		combinedData_t* pData = call SharedData.getAllData();
		if (pData->routePrivData.isValid)
		{
			return pData->routePrivData.parentNodeId;
			
		}
		else
		{
			//TODO go through whole table	
		}
		return 0;	//TODO in case no parent found return max value that cannot appear in reality
	}
	
	task void task_getRandomParentID() {
	  	//dbg("NodeState", "KeyDistrib.task_getKeyToBS called.\n");
		//SavedData_t* pTable = call SharedData.getSavedData();
		//node_id_t randIndex = call Random.rand16() % MAX_NEIGHBOR_COUNT;
		
	}
	command error_t Route.getRandomParentID(){
		post task_getRandomParentID();
		return SUCCESS;
	}
	
	
	task void task_getRandomNeighborID() {
	  	//dbg("NodeState", "KeyDistrib.task_getKeyToBS called.\n");
		//SavedData_t* pTable = call SharedData.getSavedData();
		//node_id_t randIndex = call Random.rand16() % MAX_NEIGHBOR_COUNT;
		
	}
	command error_t Route.getRandomNeighborID(){
			post task_getRandomNeighborID();
			return SUCCESS;
	}
	
	event void Dispatcher.stateChanged(uint8_t newState){ }
	
#ifndef USE_CTP
	task void initCTP(){
		// Signalize dispatcher routing is done.
		call Dispatcher.serveState();
	}
	
	command error_t Route.getRandomNeighborIDB(node_id_t * neigh){
		// TODO: not implemented yet.
		return FAIL;
	}
	
	command error_t Route.getCTPParentIDB(node_id_t * neigh){
		return FAIL;
	}
#endif
	/*
	command error_t getParentIDs(node_id_t* ids, uint8_t maxCount);
	
	command error_t getChildrenIDs(node_id_t* ids, uint8_t maxCount);
	
	command error_t getNeighborIDs(node_id_t* ids, uint8_t maxCount);
	*/
	
#ifdef USE_CTP
/**
 *  Conditional compilation (define USE_CTP). Used only to determine random neighbor.
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
	
	task void stopCTP(){
		pl_log_i(TAG, "CTP termination state...");
		pl_printfflush();
		
		call CtpSendTimer.stop();
		call FixedTopology.setFixedTopology();
		
		// Signalize dispatcher routing is done.
		call Dispatcher.serveState();
	}

	event void CtpInitTimer.fired(){
		pl_log_d(TAG, "CTPtimerState[%u]\n", ctp_init_state);
		pl_printfflush();
		
		if (ctp_init_state==CTP_STATE_INIT){
			// State = 0 -> start CTP sending timer.
			call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
			// Move to the next state
			ctp_init_state = CTP_STATE_SENDING;
			// Start CTP init timer for CTP stabilizing to fixed topology
			call CtpInitTimer.startOneShot(CTP_TIME_STOP_AFTER_BOOT);
			
		} else if (ctp_init_state==CTP_STATE_SENDING){
			// Move to the next state -> finish as soon as parent is found.
			ctp_init_state = CTP_STATE_FIND_PARENT;
			call CtpInitTimer.startOneShot(CTP_TIME_STOP_NO_PARENT);
			call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
			
		} else if(ctp_init_state==CTP_STATE_FIND_PARENT){
			// Stopping CTP - move to fixed topology.
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
		
		// CTP didn't returned a response
		if (ctpBusy){
			ctpBusyCount+=1;
			pl_log_w(TAG, "CTPSendTask, busy[%u]\n", ctpBusyCount);
			
			// start re-tx timer, if aperiodic timer is choosen
			call CtpSendTimer.startOneShot(CTP_TIME_SEND_FAIL + (call Random.rand16() % CTP_TIME_SEND_FAIL_RND));
			return;
		}
		
		// Terminate if CTP is not in use anymore.
		if (ctp_init_state>=CTP_STATE_TERMINATE){
			// CTP ended
			return;
		}
		
		pl_log_d(TAG, "CTPinitTask()\n");

#ifdef THIS_IS_BS
		if (ctp_init_state==CTP_STATE_FIND_PARENT){
			findRootCnt += 1;
			
			// Try to help CTP somehow sometimes...
			if ((findRootCnt % 5) == 0){
				pl_log_d(TAG, "CTP route update\n");
				call CtpInfo.triggerImmediateRouteUpdate();
				call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
				return;
				
			} else if ((findRootCnt % 5) == 2) {
				pl_log_d(TAG, "CTP recompute\n");
				call CtpInfo.recomputeRoutes();
				call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
				return;
			}
					
			return;
		}
		
		// If a BS, nothing to do.
		call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
		
#else	
		// Only if given node is not a base station.
		// If we are trying to find root...
		// Helping CTP by triggering route recomputation (if parent was not found till now, something is wrong).
		if (ctp_init_state==CTP_STATE_FIND_PARENT && parentFound==FALSE){
			// State for finding root, if have one, can stop right now...
			error_t parentStatus=FAIL;
			am_addr_t parent;
			
			parentStatus = call CtpInfo.getParent(&parent);
			if (parentStatus==SUCCESS){
				pl_log_i(TAG, "Parent found: [%u]. Terminating CTP\n", parent);
				ctp_init_state=CTP_STATE_TERMINATE;
				parentFound=TRUE;
				
				return;
			} else {
				pl_log_w(TAG, "Parent NOT found. Err [%u]. Try again\n", parentStatus);
				findRootCnt += 1;
				
				// Try to help CTP somehow sometimes...
				if ((findRootCnt % 5) == 0){
					pl_log_d(TAG, "CTP route update\n");
					call CtpInfo.triggerImmediateRouteUpdate();
					call CtpSendTimer.startOneShot(CTP_TIME_SENDING + (call Random.rand16() % CTP_TIME_SENDING_RND));
					return;
					
				} else if ((findRootCnt % 5) == 2) {
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
            ctpBusy=TRUE;
            pl_log_d(TAG, "CTPSendTask, sending\n");
            
        } else {
        	// log fail
        	pl_log_w(TAG, "CTPSendTask, send failed, %u\n", sendResult);
        	
        	// start re-tx timer
			call CtpSendTimer.startOneShot(CTP_TIME_SEND_FAIL + (call Random.rand16() % CTP_TIME_SEND_FAIL_RND));
        }
#endif
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
	
	/* Is this quality measure better than the minimum threshold? */
    // Implemented assuming quality is EETX
    bool passLinkEtxThreshold(uint16_t etx) {
        return (etx < ETX_THRESHOLD);
    }
    
	command error_t Route.getRandomNeighborIDB(node_id_t * neigh){
#ifndef THIS_IS_BS	
		uint8_t numNeigh = 0;
		
		// Obtain number of neighbors from CTP component.
		numNeigh = call CtpInfo.numNeighbors();
		pl_log_d(TAG, "getRandNeigh, num=%u\n", numNeigh);
		
		// If zero -> nothing to do...
		if (numNeigh == 0){
			return FAIL;
		} else {
			uint8_t i=0;
			uint8_t numAboveThreshold=0;
			uint8_t acceptableNeigh[CTP_MAX_RAND_NEIGH];
			uint8_t chosenOne;
			for(i=0; i<CTP_MAX_RAND_NEIGH; i++){ 
				acceptableNeigh[i] = CTP_MAX_NEIGH;
			}
			
			// Iterate over, neighbors, pick only those with quality above threshold.
			for(i=0; i<numNeigh; i++){
				uint16_t linkQuality = call CtpInfo.getNeighborLinkQuality(i);
				if (passLinkEtxThreshold(linkQuality)){
					acceptableNeigh[numAboveThreshold++] = i;
				}
			}
			
			pl_log_d(TAG, "getRandNeigh, %u neigh above threshold\n", numAboveThreshold);
			
			// If 0 above threshold -> fail
			if (numAboveThreshold){
				return FAIL;
			}
			
			chosenOne = call Random.rand16() % numAboveThreshold;
			*neigh = call CtpInfo.getNeighborAddr(acceptableNeigh[chosenOne]);
			return SUCCESS;
		}
#endif
		return FAIL;
	}
	
	command error_t Route.getCTPParentIDB(node_id_t * parent){
		return call CtpInfo.getParent(parent);
	}
#endif
}

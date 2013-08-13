/**
 * The implementation of privacy component. It is abstracted by configuration PrivacyC.
 * 
 * 	@version   0.1
 * 	@date      2012-2013
 * 
 **/

#include "ProtectLayerGlobals.h"
#include "printf.h"

module PrivacyP {
	uses {
		interface AMSend as LowerAMSend;
		interface Receive as LowerReceive;
		interface Packet;
		interface AMPacket;
		interface SplitControl as AMControl;
		interface IntrusionDetect;
		interface Init as IntrusionDetectInit;
		interface Init as ePIRInit;
		interface Route;
		interface RoutingTable;
		interface SharedData;
		interface Crypto;
		interface Pool<message_t> as Pool;
		interface Queue<message_t*> as SendQueue;
		interface Queue<uint8_t> as SendOrder;
		interface XXTEA;
		interface Timer<TMilli> as CheckParentTimer;
		interface Timer<TMilli> as SendTimer;
		interface Timer<TMilli> as ExperimentTimer;
		interface Stats;
		interface Leds;
		interface CC2420Packet;
		interface Random;
		interface ParameterInit<uint16_t> as RandomInit;
		#ifndef TOSSIM
		interface Logger;
		#endif
	}

	provides {
		interface Init;

		interface Experiment;
		interface AMSend as PrivateSend;
		interface AMSend as ForwardSend;
		interface Receive as PrivateReceive;
		interface SplitControl as PrivateAMControl;
		interface Packet as PrivatePacket;

		// parameterized interfaces for different message types
		interface Receive as MessageReceive[uint8_t id];
		//interface AMPacket as MessageAMPacket;	// TODO: implement
	}
}
implementation {

	uint8_t reputation;

	bool m_radioBusy = FALSE;
	message_t * m_lastMsg = NULL;
	uint8_t m_lastMsgSender = 0;
	SendRequest_t m_sendBuffer[COUNT_SEND];
	uint8_t m_nextId = 0;
	message_t * m_canceledMsg = NULL;
	message_t dummyMsg;
	// receive buffer
	message_t m_receiveMemoryBuffer[RECEIVE_BUFFER_LEN];
	RecMsg_t m_receiveBuffer[RECEIVE_BUFFER_LEN];
	uint8_t m_recNextToProcess = 0;
	uint8_t m_recNextToStore = 0;
	// msgs for  IDS copy
	message_t m_msgMemoryForIDS;
	RecMsg_t m_msgForIDS;
	//processing receive msgs
	uint8_t m_receiveState = REC_STATE_FROM_ALL;
	uint8_t m_nonce[NONCE_LEN];
	uint8_t initFlag = 0; 
	
	uint8_t m_experimentState = EXPERIMENT_START;

	uint8_t m_messageBufferCounter=0;
	
	uint16_t m_experimentSent=0;
	
	
	//
	//	Init interface
	//
	command error_t Init.init() {

		uint8_t i = 0;
		uint8_t *payload;
		

		//init receive buffer
		for(i = 0; i < RECEIVE_BUFFER_LEN; i++) {
			m_receiveBuffer[i].msg = &m_receiveMemoryBuffer[i];
			m_receiveBuffer[i].isEmpty = 1;
		}
	
		//init dummy packet
		payload = call Packet.getPayload(&dummyMsg, PACKET_LEN);
		memcpy(payload, "Dummy message      ",PACKET_LEN);
	
		
	
		//init IDS copy msg
		m_msgForIDS.msg = &m_msgMemoryForIDS;
	
		call RandomInit.init(TOS_NODE_ID);
		
		call IntrusionDetectInit.init();
		//printf("case 0\n");
		
		dbg("Privacy", "Privacy component initialization...\n");
		return SUCCESS;
	}
	
	

	void passToIDS(message_t * msg, void * payload, uint8_t len) {
		// copy message content to IDS msg
		memcpy(m_msgForIDS.msg, msg, sizeof(message_t));
		m_msgForIDS.payload = call Packet.getPayload(m_msgForIDS.msg, len);
		m_msgForIDS.len = len;

		// signal to IDS and update memory field for next msg
		m_msgForIDS.msg = signal MessageReceive.receive[MSG_IDSCOPY](m_msgForIDS.msg,
				m_msgForIDS.payload, m_msgForIDS.len);

	}

	
	//
	// Receive interface - LowerReceive
	//
	task void task_receiveMessage() {

		message_t * retMsg = NULL;
		message_t * msg;
		uint8_t len = 0;
		uint8_t * payload;
		am_addr_t sourceId;
		uint8_t nonce[NONCE_LEN];
		error_t retVal = SUCCESS;
		ParentData_t* parent;
		uint8_t i;
		int cmp=0;
		


//		if(m_receiveState != REC_STATE_FROM_ALL) {
//			dbg("Privacy","task_receiveMessage, state FROM CHILD 2\n");
//			//post task_receiveMessage();
//			return;
//		}
		
		// Get msg to be processed
		if (m_receiveBuffer[m_recNextToProcess].isEmpty)
		{
			dbg("Privacy","PrivacyP, task_sendMessage, m_receiveBuffer is empty.\n");
			return;
		}
		msg = m_receiveBuffer[m_recNextToProcess].msg;
		sourceId = call AMPacket.source(msg);

		
		// is sender in the children list ?
		if(call RoutingTable.containsChild(sourceId)) {
			//dbg("Privacy","task_receiveMessage, msg from child 3\n");
				
			//FOR SIGNAL TESTING ONLY
//			//check if message is corrupted
//			
//			//printf("RSSI %d\n", call CC2420Packet.getRssi(msg));
//			//printf("LQI %u\n", call CC2420Packet.getLqi(msg));
//			
//			//printf("from child\n");
//			//printfflush();
			
//			call Leds.led1Toggle();
//			cmp = memcmp(m_receiveBuffer[m_recNextToProcess].payload, "Dummy message      ",PACKET_LEN);
//			if (cmp==0)
//			{
//				//no corruption
//				call RoutingTable.increaseReceiveCount(sourceId);
//				call Stats.dummyMessageReceived();
//			}	else
//			{
//				call RoutingTable.increaseModifCount(sourceId);
//				call Stats.corruptedMessageReceived();
//				
//			}
//			retMsg = msg;
//			//END FOR SIGNAL TESTING
				
			call Stats.messageReceived();	
			
				
			retMsg = signal MessageReceive.receive[MSG_FORWARD](m_receiveBuffer[m_recNextToProcess].msg,
					m_receiveBuffer[m_recNextToProcess].payload,
					m_receiveBuffer[m_recNextToProcess].len);
			
			
			if (call RoutingTable.amiBS())
			{
				// I am BS and have no parnet, thus I shall not forward the message and hence cannot switch to other receive state, othewise I shall never receive anything else
			}
			else
			{
			//m_receiveState = REC_STATE_FROM_CHILD;
			}

		}
		// is sender in the parents list ?
		else if(call RoutingTable.containsParent(sourceId)) {
						
			// Packet sent by our parent, check for drop...
			call Stats.parentMessageReceived();
			
			//printf("from parent\n");
			//printfflush();
			
		//	(uint16_t) call CC2420Packet.getRssi(msg); getLqi()
			
			
			parent = call RoutingTable.getParent(sourceId);
			//dbg("Privacy","task_receiveMessage, msg from parent 3\n");
			// check if mac is expected
			//get MAC from packet
			payload = (uint8_t*) m_receiveBuffer[m_recNextToProcess].payload;
			
//			printf("message payload %d %d %d %d\n", payload[0], payload[1], payload[2], payload[3]);
//			printfflush();
			
			for(i=0;i<EXPECTED_BUFF_LEN;i++)
			{
				if (!(parent->expMAC[i].isEmpty))
				{
					
					//printf("exp. mac %u, obtained mac %u\n", parent->expMAC[i].MAC[0], payload[NONCE_LEN+MSG_LEN]);
					//	printfflush();
					if (memcmp(parent->expMAC[i].MAC,payload+NONCE_LEN+MSG_LEN,MAC_LEN)==0)
					{
						// valid and expected MAC, remove it from the list
						parent->expMAC[i].isEmpty=1;
						parent->sentCount++;
						call Stats.idsMessageForwarded();
//						printf("message forwarded\n");
//						printfflush();
						dbg("Privacy","Message forwarded by parent.\n");
						break;
					}	
				}
			}
			retMsg = msg;
		}
		// otherwise 
		else {
			
			//printf("from other\n");
			//printfflush();
			
			//dbg("Privacy", "task_receiveMessage, Message sender not recognized 3\n");
			// It is not for me, pass copy to IDS
			//passToIDS(msg, m_receiveBuffer[m_recNextToProcess].payload, m_receiveBuffer[m_recNextToProcess].len);
			retMsg = msg;
		}

		// empty message_t slot, update which slot to process next and end task
		m_receiveBuffer[m_recNextToProcess].msg = retMsg;
		m_receiveBuffer[m_recNextToProcess].isEmpty = 1;
		m_recNextToProcess = (m_recNextToProcess + 1) % RECEIVE_BUFFER_LEN;
		m_messageBufferCounter--;
		//dbg("Privacy","ReceiveBuffer -- %hhu\n",m_messageBufferCounter);

		return;
	}

	event message_t * LowerReceive.receive(message_t * msg, void * payload,
			uint8_t len) {
		message_t * tmpMsg = NULL;

		//dbg("Privacy", "PrivacyP LowerReceive.receive, msg received 1\n");
		
		//get new message_t to be returned
		if(m_receiveBuffer[m_recNextToStore].isEmpty) {
			tmpMsg = m_receiveBuffer[m_recNextToStore].msg;
			m_receiveBuffer[m_recNextToStore].msg = msg;
			m_receiveBuffer[m_recNextToStore].payload = payload;
			m_receiveBuffer[m_recNextToStore].len = len;
			m_receiveBuffer[m_recNextToStore].isEmpty = 0;
			m_recNextToStore = (m_recNextToStore + 1) % RECEIVE_BUFFER_LEN; // update pointer to next position to which next msg will be stored 
			m_messageBufferCounter++;
			//dbg("Privacy","ReceiveBuffer ++ %hhu\n",m_messageBufferCounter);
		}
		else {
			//buffer full, return original message without modification
			printf("Error PrivacyP LowerReceive.receive, buffer full\n");
			printfflush();
			return msg;
		}

		call Leds.led0Toggle();
		post task_receiveMessage();

		return tmpMsg;
	}

	task void task_sendMessage() {
		error_t rval = SUCCESS;
		uint8_t count = 0;
		SendRequest_t sReq;
		//dbg("Privacy","task_sendMessage 2\n");
		//PrintDbg("PrivacyP", "task_SendMessage\n");// check if radio is busy or not
		
		if(m_radioBusy) 
		{
			PrintDbg("Error","PrivacyP, task_sendMessage, radio is busy. \n");
			post task_sendMessage();
			return;
		}
		//find next message to send in buffer
		
		if (call SendOrder.empty())
		{
			//dbg("Privacy","task_sendMessage, nothing in the buffer\n");
			// empty buffer, send dummy message
			m_lastMsg = &dummyMsg;
			m_lastMsgSender = DUMMY_SEND;
			rval = call LowerAMSend.send(AM_BROADCAST_ADDR, &dummyMsg, PACKET_LEN);
				if(rval != SUCCESS) {
					PrintDbg("Error", "Error sending dummy packet.\n");
					
				}
			call Leds.led2On();
			return; //no message to send, buffer is empty
		} else
		{
		m_nextId = call SendOrder.dequeue();
		}

		//get info SendRequest from m_buffer
		sReq.addr = m_sendBuffer[m_nextId].addr;
		sReq.msg = m_sendBuffer[m_nextId].msg;
		sReq.len = m_sendBuffer[m_nextId].len;

		// store msg pointer for further check in sendDone	
		m_lastMsg = sReq.msg;
		m_lastMsgSender = m_nextId;

		//dbg("Privacy", "task_sendMessage 3, sending MSG type %d\n",	m_nextId);

		
		rval = call LowerAMSend.send(sReq.addr, sReq.msg, sReq.len);
		if(rval == SUCCESS) {
			//sent succesfully, clear buffer and increase id
			if(m_nextId == FORWARD_SEND) {
				//m_receiveState = REC_STATE_FROM_ALL;
				//post task_receiveMessage();
			}
			m_sendBuffer[m_nextId].addr = 0;
			m_sendBuffer[m_nextId].msg = NULL;
			m_sendBuffer[m_nextId].len = 0;
			m_nextId = (m_nextId + 1) % COUNT_SEND;
			m_radioBusy = TRUE;
			//call Leds.led1On();
		}
		else {
			// TODO: if rval is not SUCCESS
			dbg("Error", "PrivacyP.task_messageSend, lowerAMSend returned error\n");
		}
		return;
	}

	void generateNewNonce(uint8_t nonce[NONCE_LEN]) {
		// generate in a deterministic way for now, should be random
		uint8_t i;

		for(i = 0; i < NONCE_LEN; i++) {
			nonce[i] = i;
		}

	}

	command error_t PrivateSend.send(am_addr_t addr, message_t* msg, uint8_t len)
	 {	
		uint8_t nonce[NONCE_LEN];
		uint8_t *payload = call Packet.getPayload(msg, len);
		uint8_t i;
		
		//dbg("Privacy","PrivateSend.send, 1\n");
		// check if radio is busy for this id
		if(m_sendBuffer[PRIVATE_SEND].msg != NULL) {
			dbg("Error","PrivacyP.MessageSend.send, buffer for id %d is full\n",PRIVATE_SEND);
			return EBUSY;
		}
		
		//get parent address, we only have one parent
		addr = call RoutingTable.getParentAddress(0);
		if(addr == AM_BROADCAST_ADDR) {
			//no parent, do  not send anything
			dbg("Error", "NO parent found, do not send anything\n");
			signal PrivateSend.sendDone(msg, SUCCESS);
			return SUCCESS;
		}
		
		
		//dbg("Privacy","PrivateSend.send message: ");
		//		for (i=0;i<MSG_LEN;i++)
		//		{
		//			dbg_clear("Privacy","%hhu ",payload[i]);
		//		}
		//		dbg("Privacy","\n");
		
		generateNewNonce(nonce);

		
		call Crypto.envelopeMsg(addr, msg, &len, nonce);

		// put message into buffer
		m_sendBuffer[PRIVATE_SEND].addr = AM_BROADCAST_ADDR; // we are broadcasting
		m_sendBuffer[PRIVATE_SEND].msg = msg;
		m_sendBuffer[PRIVATE_SEND].len = len;

		// put send request into queue
		call SendOrder.enqueue(PRIVATE_SEND);
		
		// is the radio busy?
		if(! m_radioBusy) 
		{
		//	post task_sendMessage();
		}
		return SUCCESS;
	}

	command error_t PrivateSend.cancel(message_t * msg) {
		return FAIL;
	}

	command void * PrivateSend.getPayload(message_t * msg, uint8_t len) {

		return call LowerAMSend.getPayload(msg, len);
	}

	command uint8_t PrivateSend.maxPayloadLength() {
		return(uint8_t)(call LowerAMSend.maxPayloadLength());
	}

	command error_t ForwardSend.send(am_addr_t addr, message_t * msg,
			uint8_t len) {

		// check if radio is busy for this id
		if(m_sendBuffer[FORWARD_SEND].msg != NULL) {
			dbg("Error", "PrivacyP.ForwardSend.send, buffer for forward send is full\n");

			return EBUSY;
		}

		// put message into buffer
		m_sendBuffer[FORWARD_SEND].addr = AM_BROADCAST_ADDR; // we are broadcasting
		m_sendBuffer[FORWARD_SEND].msg = msg;
		m_sendBuffer[FORWARD_SEND].len = len;
		
		// put send request into queue
		call SendOrder.enqueue(FORWARD_SEND);

		// is the radio busy?
		if(! m_radioBusy) 
			{
				//post task_sendMessage();
			}

		return SUCCESS;
	}

	command error_t ForwardSend.cancel(message_t * msg) {
		return FAIL;
	}

	command void * ForwardSend.getPayload(message_t * msg, uint8_t len) {

		return call LowerAMSend.getPayload(msg, len);
	}

	command uint8_t ForwardSend.maxPayloadLength() {
		return(uint8_t)(call LowerAMSend.maxPayloadLength());
	}

	//
	// MessageReceive
	//
	default event message_t * MessageReceive.receive[uint8_t id](message_t * msg,
			void * payload, uint8_t len) {
		return msg;
	}
	//
	//	LowerAMSend interface
	//
	event void LowerAMSend.sendDone(message_t * msg, error_t error) {
		//test if our message was sent
		if(m_lastMsg != msg) 
		{
			dbg("Error","LowerAMSend.sendDone signals for another msg.\n");
			return;
		}
		//dbg("Privacy","Privacy: PrivacyP.LowerAMSend.sendDone, radio not busy from now\n");
		// radio not busy
		m_radioBusy = FALSE;
		//call Leds.led0Off();
		//call Leds.led1Off();
		call Leds.led2Off();
		//post task_sendMessage();
		// Signal to particular interface 
		switch (m_lastMsgSender)
		{
			case PRIVATE_SEND:
			{
				call Stats.eventMessageSent();
				signal PrivateSend.sendDone(msg, error);
				break;
			}
			case FORWARD_SEND:
			{
				//m_receiveState = REC_STATE_FROM_ALL;
				call Stats.messageForwarded();
				signal ForwardSend.sendDone(msg, error);
				break;
			}
			case DUMMY_SEND:
			{
				call Stats.dummyMessageSent();
				break;	
			}
		}
	}

	//
	// RoutingTable interface
	//
	event void RoutingTable.initDone(error_t err) {

	}

	//
	// AMControl interface
	//  
	event void AMControl.startDone(error_t err) {
		if(err == SUCCESS) {
			// signal to upper layers
			signal PrivateAMControl.startDone(err);
		}
		else {
			// try to restart again
			call AMControl.start();
		}
	}
	event void AMControl.stopDone(error_t err) {
		// do nothing
	}

	//
	// PrivateAMControl (aka SplitPhase) interface
	//	
	command error_t PrivateAMControl.start() {
		//printf("PrivacyP.MessageAMControl.start() entered\n");
		// TODO: if our AMControl is not running yet, start it 
		dbg("Privacy", "PrivateAMControl starting approach.\n");
		call AMControl.start();

		return SUCCESS;
	}
	command error_t PrivateAMControl.stop() {
		return SUCCESS;
	}
	default event void PrivateAMControl.startDone(error_t err) {
	}

	//
	//	MessagePacket
	//	
	command void PrivatePacket.clear(message_t * msg) {
		call Packet.clear(msg);
	}
	command uint8_t PrivatePacket.payloadLength(message_t * msg) {
		return(uint8_t)(call Packet.payloadLength(msg));
	}
	command void PrivatePacket.setPayloadLength(message_t * msg, uint8_t len) {
		call Packet.setPayloadLength(msg, (uint8_t)(len));
	}
	command uint8_t PrivatePacket.maxPayloadLength() {
		return(uint8_t)(call Packet.maxPayloadLength());
	}
	command void * PrivatePacket.getPayload(message_t * msg, uint8_t len) {
		
		// Return payload offset 
		return call Packet.getPayload(msg, (nx_uint8_t)(len));
	}

	//
	// Route
	//
	event void Route.randomNeighborIDprovided(error_t status, node_id_t id) {
		// do nothing
	}
	event void Route.randomParentIDprovided(error_t status, node_id_t id) {
		// do nothing
	}


	//
	// interface Logger
	//
	#ifndef TOSSIM
	event void Logger.logToPCDone(message_t * msg, error_t error) {
		// TODO Auto-generated method stub
	}
	#endif

	event void CheckParentTimer.fired(){
		
		uint8_t i;
		ParentData_t* parent;
		uint32_t currentTime;
		
		//dbg("SimulationLog", "CheckParentTimer fired.\n");
		//check parent expected MACs
		parent = call RoutingTable.getParent(call RoutingTable.getParentAddress(0));
		
		if (parent==NULL)
		{
			//no parent found
			dbg("Error","No parent found for checkParentTimer.\n");
			return;
		}
		
		// get current time
		currentTime = call CheckParentTimer.getNow();
		
		for(i=0;i<EXPECTED_BUFF_LEN;i++)
		{
			if (!(parent->expMAC[i].isEmpty))
			{
//				printf("Check parent timer, current %lu, sent %lu \n", currentTime, parent->expMAC[i].timeSent);	
//				printfflush();
				dbg("Privacy","current time: %u timeSent: %u\n",currentTime, parent->expMAC[i].timeSent);
				if ((currentTime - parent->expMAC[i].timeSent) > IDS_THRESHOLD_TIME)		
				{
					// valid and expected MAC, remove it from the list
//					printf("Attack, message dropped\n");
//					printfflush();
					call Stats.idsMessageDropped();
					parent->dropCount++;
					parent->expMAC[i].isEmpty=1;
				}
			}
		}
	}
	
	event void SendTimer.fired(){
		
			if (m_experimentState == EXPERIMENT_BOOTSTRAP)
			{
				if (m_experimentSent<EXPERIMENT_BOOTSTRAP_MSG_COUNT)
				{
					post task_sendMessage();
					m_experimentSent++;
				}
			} else
			{
				post task_sendMessage();
			}
		}
		
	event void ExperimentTimer.fired()
	{
		
		switch (m_experimentState)
		{
			case EXPERIMENT_START: {
				// start experiment actually
				m_experimentState = EXPERIMENT_BOOTSTRAP;
				// start sending messages
				call SendTimer.startPeriodic(SEND_TIME);
				call ExperimentTimer.startOneShot(100);  //EXPERIMENT_BOOTSTRAP_TIME);
				
				break;
				}
			case EXPERIMENT_BOOTSTRAP: {
				m_experimentState = EXPERIMENT_RUNNING;
				//call RoutingTable.setThresholdIDS(call Stats.getParentLinkQuality());
				call RoutingTable.setThresholdIDS(EXPERIMENT_IDS_THRESHOLD);
				call ExperimentTimer.startOneShot(SIMULATION_TIME);
				if (TOS_NODE_ID == EXPERIMENT_SOURCE_ID || TOS_NODE_ID == EXPERIMENT_SOURCE_ID2){
					call ePIRInit.init();
				}
				call CheckParentTimer.startPeriodic(IDS_THRESHOLD_TIME);
//				printf("started experiment\n");
//				printfflush();
				break;				
			}
			case EXPERIMENT_RUNNING: {
				// end experiment and wait for other nodes
				m_experimentState = EXPERIMENT_END;
				call SendTimer.stop();
				call ExperimentTimer.startOneShot(DELAY_TIME);
				
				break;
				}
			case EXPERIMENT_END: {
				
				call CheckParentTimer.stop();
				m_experimentState = EXPERIMENT_START;
				signal Experiment.ended();
				
				break;
				}
				
		}

		
	}	
	//interface Experiment
	command void Experiment.startExperiment()
	{
		switch (m_experimentState)
		{
			case EXPERIMENT_START: {
				
				call Stats.nextTest();
				call ExperimentTimer.startOneShot(DELAY_TIME);
				// start sending messages
				break;
				}
			default: {
				break;
				}		
		}		
	}
}
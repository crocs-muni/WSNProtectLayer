/*
 * "Copyright (c) 2012-2012 XXX.  
 *
 */

/**
 * Implementation of the ...
 *
 * @author Petr Svenda
 * @date   Jul 16, 2012
 */
#include <Timer.h>
#include "ProtectLayerGlobals.h" 

module UserApp1P {
	uses {
		interface MovementSensor as MovementSensor1;
		interface AMSend as AppMessagesSend;
		interface Receive as AppMessagesReceive;
		interface Timer<TMilli> as Timer0;
	}
	provides {
		interface Init;
	}
}
implementation {
	message_t 	pkt;
	bool busy = FALSE;
  
	error_t prepareAndSendAppMessage(uint8_t appID, uint8_t msgType, uint8_t info) {
		error_t stat = SUCCESS;
		// If not busy, then create new packet for BS informing about detected movement
		if (!busy) {
			AppMsg_t* appData = (AppMsg_t*)(call AppMessagesSend.getPayload(&pkt, sizeof(AppMsg_t)));
			if (appData == NULL) return EINVAL;
			appData->appID = appID;
			appData->myType = msgType;
			appData->info = info;	
			if ((stat = call AppMessagesSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(AppMsg_t))) == SUCCESS) {
				busy = TRUE;
			}
		} 
		else stat = EBUSY;
		return stat;
	}
  
	event void MovementSensor1.movementDetected() {
		prepareAndSendAppMessage(APPID_POLICE, APPMSG_MOVEMENT, 1);
	} 
/*
	event void MovementSensor2.movementDetected() {
		prepareAndSendAppMessage(APPID_POLICE, APPMSG_MOVEMENT, 2);
	} 	
*/	
	event void Timer0.fired() { 
		// peridic still allive message
		prepareAndSendAppMessage(APPID_POLICE, APPMSG_MOVEMENT, 0);
	}
	
	command error_t Init.init() {
	      call Timer0.startPeriodic(POLICEMAN_TIMER_MESSAGE_MILLI); 
		  return SUCCESS;
	}
	
	event void AppMessagesSend.sendDone(message_t* msg, error_t error) {
		if (&pkt == msg) {
			busy = FALSE;
		}	
	}	
	
	event message_t* AppMessagesReceive.receive(message_t* msg, void* payload, uint8_t len) {
		// Take info from header
		AppMsg_t* appHeader = (AppMsg_t*) payload;

		if (appHeader->appID == APPID_POLICE) {
			// TODO: do something with that
		}
		return msg;
	}	

}

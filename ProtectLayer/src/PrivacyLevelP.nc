/**
 * Implementation of privacy level abstraction. It takes care of the privacy level interchange. 
 * It should implement the mechanism for privacy level interchange and handle privacy level related messages received.
 * The component implements PrivacyLevel interface.
 * 
 * 	@version   0.1
 * 	@date      2012-2013
 **/


#include "ProtectLayerGlobals.h"
module PrivacyLevelP{
	uses {
		interface AMSend;
		interface Receive;
		interface Crypto;
		interface Timer<TMilli> as TimerP; //testing
		interface Privacy;
	}
	provides {
		interface Init;
		interface PrivacyLevel;
	}
}
implementation{
	message_t m_msg;
	bool m_radioBusy=FALSE;
	

	
	
	task void task_sendMessage() {
	  	error_t rval=SUCCESS;
	  	//dbg("Privacy", "Privacy: PrivacyLevelP.task_sendMessage called.\n");
				
		//if (!m_msgToSend) {
		//	return;
		//}
		
		rval = call AMSend.send(AM_BROADCAST_ADDR, &m_msg, sizeof(PLevelMsg_t));
	    if (rval == SUCCESS) {
	        m_radioBusy = TRUE;
	    //    m_msgToSend = FALSE;
	   		dbg("Privacy", "Privacy: PrivacyLevelP.task_sendMessage send returned %d.\n",rval);
	        return;
	    }
		return;
	}
	
	//testing
	//TimerPL
	//
	event void TimerP.fired() {
		PRIVACY_LEVEL privLevel; 
		error_t rval=SUCCESS;
		
		dbg("Privacy","Privacy: PrivacyLevelP.TimerP.fired, timer fired\n");
	
		privLevel = call Privacy.getCurrentPrivacyLevel();
		
		
			
		    if (!m_radioBusy) {
		      PLevelMsg_t* pkt = (PLevelMsg_t*)(call AMSend.getPayload(&m_msg, sizeof(PLevelMsg_t)));
		      if (pkt == NULL) {
				return;
		      }
		      pkt->newPLevel = PLEVEL_1;
		      // send message
		      rval = call AMSend.send(AM_BROADCAST_ADDR, &m_msg, sizeof(PLevelMsg_t));
			  if (rval == SUCCESS) {
			      m_radioBusy = TRUE;
			      dbg("Privacy", "Privacy: PrivacyLevelP.TimerP.fired send returned %d.\n",rval);
			    }
			}
	}
	
	
	//
	// Init interface
	//
	command error_t Init.init(){
		dbg("Privacy","Privacy: PrivacyLevelP.Init.init, starting timer\n");
		//call TimerP.startPeriodic(100); //testing
		return SUCCESS;
	}
	
	//
	//	Receive Interface
	//
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		
		if (len == sizeof(PLevelMsg_t)) {
    		PLevelMsg_t *pkt = (PLevelMsg_t *) payload;
    		//check if new priv level is valid
    		if (pkt->newPLevel <= PLEVEL_2)	{
    			dbg("Privacy","Privacy: PrivacyLevelP.Receive.receive, received and plevel set to: %d\n",pkt->newPLevel);
				signal PrivacyLevel.privacyLevelChanged(SUCCESS, pkt->newPLevel);
			}
		}
		return msg;	
	}
	
	//
	// AMSend interface
	//
	
	event void AMSend.sendDone(message_t *msg, error_t error){
		dbg("Privacy","Privacy: PrivacyLevelP.AMSend.sendDone\n");
		if (msg==&m_msg)
			m_radioBusy=FALSE;
	}
	
	/*
	//
	// Crypto interface
	//
	event void Crypto.decryptBufferDone(error_t status, uint8_t *buffer, uint8_t resultLen){
		// not used
	}
	event void Crypto.deriveKeyDone(error_t status, PL_key_t *derivedKey){
		// not used
	}
	event void Crypto.encryptBufferDone(error_t status, uint8_t *buffer, uint8_t resultLen){
		//not used
	}
	event void Crypto.generateKeyDone(error_t status, PL_key_t *newKey){
		//not used
	}
	*/
	
	
	
	
}

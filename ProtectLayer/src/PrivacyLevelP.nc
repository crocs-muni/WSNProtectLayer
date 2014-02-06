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
#ifndef THIS_IS_BS	
	uses {
		interface AMSend;
		interface Receive;
		interface Crypto;
		interface Privacy;
		interface SharedData;
	}
#endif
	provides {
		interface Init;
		interface Init as PLInit;
		interface PrivacyLevel;
		interface MagicPacket;
	}
}
implementation{
#ifndef THIS_IS_BS	
	message_t m_msgMemory;
	message_t* m_msg;
	message_t* m_lastMsg;
	uint16_t m_len=0;
 	bool m_busy = TRUE;
 	
 	PPCPrivData_t* ppcPrivData = NULL;
	
	// Logging tag for this component
    static const char *TAG = "PlevelP";
	
	task void sendTask();
	
	//
	// Init interface
	//
	command error_t Init.init(){
		m_msg = &m_msgMemory;
		m_busy=FALSE;
		return SUCCESS;
	}
	
	/**
	 * PL init interface, initializes shared data.
	 */
	command error_t PLInit.init(){
        ppcPrivData = call SharedData.getPPCPrivData();
        if(ppcPrivData == NULL){
	    	pl_log_e(TAG, "PLinit, ppcPrivData not retreived.\n");
	    	return FAIL;	    
        }
        
        pl_log_d(TAG, "PLinit, data=%p\n", ppcPrivData);
        return SUCCESS;		
	}
	
	//
	//	Receive Interface
	//
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		if (len == sizeof(PLevelMsg_t)) {
    		PLevelMsg_t *pkt = (PLevelMsg_t *) payload;
    		error_t sigValid = FAIL;
    		Signature_t sig;
    		bool magicPacket = FALSE;
    		
    		//check if new priv level is valid
    		if (pkt->newPLevel >= PLEVEL_NUM) {
    			pl_log_w(TAG, "privacy level not recognized [%x]\n", pkt->newPLevel);
    			return msg;
    		}
    		
			// Global counter has to be strictly less than given counter in the message.
	        if (ppcPrivData->global_counter >= pkt->counter){
	        	pl_log_d(TAG, "global counter[%u] >= counter[%u]\n", ppcPrivData->global_counter, pkt->counter);
	        	return msg;
	        }
			
			pl_log_d(TAG, "plevel changed msg, new=%u\n", pkt->newPLevel);
			
			// Verify auth broadcast (w.r.t. BS)
			// Signature is placed after payload, like MAC.
#ifdef ACCEPT_ALL_SIGNATURES
			sigValid = SUCCESS;
#else
			sigValid = call Crypto.verifySignature((uint8_t*) (&(pkt->signature)), 0, pkt->newPLevel, pkt->counter, &sig);
#endif
			if (sigValid != SUCCESS){
				pl_log_i(TAG, "plevel sig invalid!\n");
				return msg;
			}
			
			atomic{
			// Magic packet = first change of the privacy level.
			magicPacket = ppcPrivData->global_counter == 0;
			
			// Signature valid -> update signature & global counter
			ppcPrivData->global_counter = pkt->counter;
			}
			
#ifndef ACCEPT_ALL_SIGNATURES
			call Crypto.updateSignature(&sig);
#endif
			
			// Signal to Privacy component new privacy level
			signal PrivacyLevel.privacyLevelChanged(SUCCESS, pkt->newPLevel);
			
			// Signal magic packet
			if (magicPacket){
				signal MagicPacket.magicPacketReceived(SUCCESS, pkt->newPLevel);
			}
			
			// Signature valid -> re-broadcast this message
			if (m_busy)
			{
				// Radio busy, packet cannot be sent. Return the same buffer
				// as given.
				return msg; 	
			}
			else
			{
				// Send packet. Return m_msg as a new buffer to store new
				// messages. m_lastMsg = msg is now in use (will be sent).
				// In m_msg is an unused buffer that can be returned.
				atomic{
				m_lastMsg = msg;
				m_len = len;
				m_busy = TRUE;
				}
				pl_printf("PL: re-bcast add; 2send=%p, free=%p\n", m_lastMsg, m_msg);
				
				post sendTask();
				return m_msg;
			}
		}
		
		return msg;	
	}
	
	//
	// interface AMSend
	//
	event void AMSend.sendDone(message_t *msg, error_t error){		
		if (m_lastMsg == msg) {
			// Send operation over msg is done, thus this buffer
			// can be recycled for next use.
			atomic{
			m_msg = msg;
			m_busy = FALSE;
			}
			
			pl_printf("PL: rebcasted msg=%p err=%d\n", msg, error);
    	}
	}
	
	task void sendTask(){
		if (m_busy==FALSE){
			// If no message is in the buffer this task makes no sense.
			return;
		}	
	
		if (call AMSend.send(AM_BROADCAST_ADDR, m_lastMsg, m_len) == SUCCESS)
		{
			// Send successful, wait for sendDone event.
			// The buffer m_lastMsg is still in use (busy=true) so it cannot be
			// recycled.
		}
		else
		{
			// Send was not successful -> m_lastMsg buffer is no longer needed
			// and can be used for the next arriving message to the forwarder.
			atomic{
			m_msg = m_lastMsg;
			m_busy = FALSE;
			}	
		}
	}
	
	default event void MagicPacket.magicPacketReceived(error_t status, PRIVACY_LEVEL newPrivacyLevel){
		
	}
#else
	
	command error_t Init.init(){
		return SUCCESS;
	}
	command error_t PLInit.init(){
        return SUCCESS;		
	}
	
	default event void MagicPacket.magicPacketReceived(error_t status, PRIVACY_LEVEL newPrivacyLevel){
		
	}		
#endif
}

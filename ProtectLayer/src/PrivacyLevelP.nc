/**
 * Implementation of privacy level abstraction. It takes care of the privacy level interchange. 
 * It should implement the mechanism for privacy level interchange and handle privacy level related messages received.
 * The component implements PrivacyLevel interface.
 * 
 * 	@version   1.0
 * 	@date      2012-2014
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
		interface Timer<TMilli> as BackoffTimer;
		interface Random;
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
 	bool r_busy = TRUE;
 	
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
		r_busy=FALSE;
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
	
	/**
	 * Starts a timer for posting a re-broadcast task within a randomized window.
	 */
	void startTimer(){
		uint16_t newTime=(call Random.rand16() % MAGIC_PACKET_RANDOM_WINDOW) + MAGIC_PACKET_RANDOM_OFFSET;
		
		pl_log_d(TAG, "re-bcas in %u\n", newTime);
		call BackoffTimer.startOneShot(newTime);
	}
	
	//
	//	Receive Interface
	//
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		if (len == sizeof(PLevelMsg_t)) {
    		PLevelMsg_t *pkt = (PLevelMsg_t *) payload;
    		bool magicPacket = FALSE;
#ifndef ACCEPT_ALL_SIGNATURES
			error_t sigValid = FAIL;
			Signature_t sig;
#endif
    		
    		// Check if new priv level is valid.
    		if (pkt->newPLevel >= PLEVEL_NUM) {
    			pl_log_w(TAG, "privacy level not recognized [%x]\n", pkt->newPLevel);
    			return msg;
    		}
    		
			// Global counter has to be strictly less than given counter in the message.
	        if (ppcPrivData->global_counter >= pkt->counter){
	        	// This logging message had to be disabled since during flood there are 
	        	// many messages of these and printf slows it down.
	        	//pl_log_d(TAG, "gctr[%u]>=mctr[%u]\n", ppcPrivData->global_counter, pkt->counter);
	        	return msg;
	        }
			
			pl_log_d(TAG, "plevel changed msg, new=%u\n", pkt->newPLevel);
			
			// Verify auth broadcast (w.r.t. BS)
			// Signature is placed after payload, like MAC.
#ifndef ACCEPT_ALL_SIGNATURES
			sigValid = call Crypto.verifySignature((uint8_t*) (&(pkt->signature)), 0, pkt->newPLevel, pkt->counter, &sig);
			if (sigValid != SUCCESS){
				pl_log_i(TAG, "plevel sig invalid!\n");
				return msg;
			}
#endif
			
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
				pl_log_w(TAG, "busy\n");
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
				startTimer();
				}
				
				pl_log_d(TAG, "re-bcast add; 2send=%p, free=%p\n", m_lastMsg, m_msg);
				return m_msg;
			}
		} else {
			pl_log_e(TAG, "invalid PLchange len\n");
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
			r_busy = FALSE;
			}
			
			pl_log_d(TAG, "rebcasted msg=%p err=%d\n", msg, error);
    	}
	}
	
	event void BackoffTimer.fired(){
		post sendTask();
	}
	
	task void sendTask(){
		if (m_busy==FALSE){
			// If no message is in the buffer this task makes no sense.
			pl_log_e(TAG, "NotBusy\n");
			return;
		}
		
		if (r_busy==TRUE){
			// If no message is in the buffer this task makes no sense.
			pl_log_w(TAG, "r_busy\n");
			startTimer(); 
		}
	
		if (call AMSend.send(AM_BROADCAST_ADDR, m_lastMsg, m_len) == SUCCESS)
		{
#if PL_LOG_MAX_LEVEL >= 7
			char str[3*sizeof(message_t)];
			unsigned char * pin = m_lastMsg;
		    const char * hex = "0123456789ABCDEF";
		    char * pout = str;
		    int i = 0;
		    for(; i < m_len-1; ++i){
		        *pout++ = hex[(*pin>>4)&0xF];
		        *pout++ = hex[(*pin++)&0xF];
		        *pout++ = ':';
		    }
		    *pout++ = hex[(*pin>>4)&0xF];
		    *pout++ = hex[(*pin)&0xF];
		    *pout = 0;
		
			pl_log_s(TAG, "task_forwardMessage;msg=%s;src=%u;dst=%u;len=%u\n", str, TOS_NODE_ID, AM_BROADCAST_ADDR, m_len);
			printfflush();
#endif
			// Send successful, wait for sendDone event.
			// The buffer m_lastMsg is still in use (busy=true) so it cannot be
			// recycled.
			atomic { r_busy = TRUE; }
		}
		else
		{
			// Send was not successful -> m_lastMsg buffer is no longer needed
			// and can be used for the next arriving message to the forwarder.
			atomic{
			m_msg = m_lastMsg;
			m_busy = FALSE;
			}
			
			pl_log_e(TAG, "Cannot send\n");
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

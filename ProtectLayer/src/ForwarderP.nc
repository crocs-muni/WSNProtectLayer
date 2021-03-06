#include "ProtectLayerGlobals.h"

/**
 * Forwarding component. Used to forward received messages.
 * Receives messages that should be forwarded by the node from the Privacy component
 * and sends it back to that componenet so it can be forwarded. It is some sort of loopback.
 * 
 */
module ForwarderP 
{
	provides {
		interface Init;
		}
#ifndef THIS_IS_BS
	uses {
		interface AMSend;
		interface Receive;
		}
#endif
}
implementation{
#ifndef THIS_IS_BS
	static const char *TAG = "FwdP";

	message_t m_msgMemory;
	message_t* m_msg;
	message_t* m_lastMsg;
	uint16_t m_len=0;
 	bool m_busy = TRUE;
	
	//
	// interface Init
	//
	command error_t Init.init(){
		m_msg = &m_msgMemory;
		m_busy=FALSE;
		return SUCCESS;
	}
	
	task void sendTask();
	
	//
	// interface Receive
	//
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		//is busy?
		pl_log_d(TAG, "Forwarder Receive.receive called.\n"); 

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
			pl_log_d(TAG, "add; 2send=%p, free=%p\n", m_lastMsg, m_msg);
			
			post sendTask();
			return m_msg;
		}
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
			
			pl_log_d(TAG, "fwded msg %p err=%d\n", msg, error);
    	}
	}
	
	task void sendTask(){
		if (m_busy==FALSE){
			// If no message is in the buffer this task makes no sense.
			return;
		}	
	
		if (call AMSend.send(AM_BROADCAST_ADDR, m_lastMsg, m_len) == SUCCESS)
		{
#if PL_LOG_MAX_LEVEL >= 7
			char str[3*sizeof(message_t)];
			unsigned char * pin = (unsigned char *) m_lastMsg;
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
		
			pl_log_s(TAG, "sendTask;msg=%s;src=%u;dst=%u;len=%u\n", str, TOS_NODE_ID, AM_BROADCAST_ADDR, m_len);
			printfflush();
#endif
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
#else
	command error_t Init.init(){
		return SUCCESS;
	}
#endif
}

#include "printf.h"
module ForwarderP 
{
	provides {
		interface Init;
		}
	uses {
		interface AMSend;
		interface Receive;
		}
}
implementation{
	message_t m_msgMemory;
	message_t* m_msg;
	message_t* m_lastMsg;
 	bool m_busy = FALSE;
	
	//
	// interface Init
	//
	command error_t Init.init(){
                m_msg = &m_msgMemory;
		return SUCCESS;
	}
	
	//
	// interfrace Receive
	//
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		//is busy?
		if(TOS_NODE_ID == PRINTF_DEBUG_ID){
			printf("ForwarderP: Forwarder Receive.receive called.\n");
		}
		
		if (m_busy)
		{
			// radio busy, packet cannot be sent
			return msg; 	
		}
		else
		{
			//send packet
			m_lastMsg = msg;
			if (call AMSend.send(AM_BROADCAST_ADDR, msg, len) == SUCCESS)
			{
				m_busy = TRUE;
				return m_msg;
			}
			else
			{
				//send failed, return origianl msg
				return msg;
			}
		}
	}
	//
	// interface AMSend
	//
	event void AMSend.sendDone(message_t *msg, error_t error){		
		if (m_lastMsg == msg) {
			m_msg = msg;
      		m_busy = FALSE;
    	}
	}

}

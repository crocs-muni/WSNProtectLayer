#include "printf.h"
module ForwarderP 
{
	provides {
		interface Init;
		}
	uses {
		interface AMSend;
		interface Receive;
		interface AMPacket;
		interface Crypto;
		interface RoutingTable;
		interface Pool<message_t> as Pool; 
		interface Pool<SendRequest_t> as SendPool;
		interface Queue<SendRequest_t*> as SendQueue;
		interface Stats;
		interface Random;
		interface ParameterInit<uint16_t> as RandomInit;
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
                call RandomInit.init(TOS_NODE_ID);
		return SUCCESS;
	}
	
	
	task void task_forwardMessage()
	{
		am_addr_t sourceId;
		uint8_t nonce[NONCE_LEN];
		error_t retVal=SUCCESS;
		uint16_t parent;
		uint8_t i;
		SendRequest_t* sendReq=NULL;
		
//		printf("task_forwardMessage\n");
//		printfflush();
		
		dbg("Privacy","ForwarderP task_forwardMessage.\n");
		
		if (call SendQueue.empty())
		{
//			printf("task_forwardMessage empty queue\n");
//			printfflush();
			return;
		}	
		
		if (m_busy)
		{
			// radio busy,
			dbg("Privacy","Radio in forwarder busy.\n");
//			printf("task_forwardMessage busy\n");
//			printfflush();
			return; 	
		}
		
		
		sendReq = call SendQueue.head();
		
		sourceId = call AMPacket.source(sendReq->msg);
		
		retVal = call Crypto.depackMsg(sourceId, sendReq->msg, &(sendReq->len), nonce);
		
		if (retVal!=SUCCESS)
		{
//				printf("task_forwardMessage mac not valid\n");
//				printfflush();		
				
				//MAC not valid, increase modif counter and put msg back into pool
				call RoutingTable.increaseModifCount(sourceId);
				call SendQueue.dequeue();
				call Pool.put(sendReq->msg);
				call SendPool.put(sendReq);
				post task_forwardMessage();
				return;
		}
		else
		{
			//radio buffer for forward_send should be empty in this state
			dbg("Privacy", "MAC ok, forwarding msg\n");
			//get parent address, we only have one parent thus index 0
			parent = call RoutingTable.getParentAddress(0);
			if (parent == AM_BROADCAST_ADDR)
				{
//					printf("task_forwardMessage no parent\n");
//					printfflush();
					//no parent, do  not send anything
					dbg("Error","ForwarderP no parent found, do not send anything\n");
					call SendQueue.dequeue();
					call Pool.put(sendReq->msg);
					call SendPool.put(sendReq);
					post task_forwardMessage();
					return;
				}
				
			call Crypto.envelopeMsg(parent, sendReq->msg, &(sendReq->len), nonce);	
		
			
			//send packet
			m_lastMsg = sendReq->msg;
			if (call AMSend.send(AM_BROADCAST_ADDR, sendReq->msg, sendReq->len) == SUCCESS)
			{
//				printf("task_forwardMessage sent with success\n");
//				printfflush();
				m_busy = TRUE;
				call SendQueue.dequeue();
				// we shall put msg into pool in sendDone event handler, call Pool.put(sendReq->msg);
				call SendPool.put(sendReq);
				return;
			}
			else
			{
				
				//send failed,
				dbg("Error","ForwarderP task_forward send failed.\n");
				call SendQueue.dequeue();
				call Pool.put(sendReq->msg);
				call SendPool.put(sendReq);
				post task_forwardMessage();
				return;
			}
			
		}
	}
	
	
	//
	// interfrace Receive
	//
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
	
		bool drop = FALSE;
		SendRequest_t* sendReq=NULL;
		
		
		//this should be done after correct packet depacking and mac verification
		if (!memcmp(payload, "Dummy", 5))
		{
			// dummy message recevived
			call Stats.dummyMessageReceived();
			return msg;
		}
		
	
//		printf("Message from child received\n");
//		printfflush();
		//ATTACK
		if (TOS_NODE_ID == ATTACK_NODE_ID || TOS_NODE_ID == ATTACK_NODE_ID2)
			{
			//is attacker
				if (ATTACK_DROP_RATE > (call Random.rand32() % 100))
				{
					//drop packet
					drop = TRUE;
				} 
			}
		if (drop) 
		{
			call Stats.messageDropped();
			return msg;
		} else 
		{	
			if (!call Pool.empty() && !call SendPool.empty()) 
			{
		   		sendReq = call SendPool.get();
		   		sendReq->msg = msg;
		   		sendReq->len = len;
		   		call SendQueue.enqueue(sendReq);
		   		post task_forwardMessage();
		   		return call Pool.get();
			}
			else
			{
				dbg("Privacy","ForwarderP, receive buffer full, pool empty.\n");
				}
			
			return msg;
		}
	}
		
		
	
	
	
	//
	// interface AMSend
	//
	event void AMSend.sendDone(message_t *msg, error_t error){		
		if (m_lastMsg == msg) {
			call Pool.put(msg);
      		m_busy = FALSE;
      		post task_forwardMessage();
    	}
	}


	event void RoutingTable.initDone(error_t err){
		// TODO Auto-generated method stub
	}
}

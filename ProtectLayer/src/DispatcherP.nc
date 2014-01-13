module DispatcherP{
	uses {
		interface Receive as Lower_PL_Receive;
		interface Receive as Lower_ChangePL_Receive;
		interface Receive as Lower_IDS_Receive;	
		interface Packet;
	}
	provides {
		interface Receive as PL_Receive;
		interface Receive as IDS_Receive;
		interface Receive as ChangePL_Receive;
		interface Init;
		//interface Receive as Sniff_Receive;
	}
}
implementation{
	
	message_t memoryMsgForIDS;
	message_t * p_msgForIDS;

	command error_t Init.init()
	{
		p_msgForIDS = &memoryMsgForIDS;	
		
		return SUCCESS;
	}
	
	void passToIDS(message_t* msg, void* payload, uint8_t len)
	{
		// copy message content to IDS msg
		memcpy(p_msgForIDS,msg,sizeof(message_t));
		
		// signal to IDS and update memory field for next msg
		//p_msgForIDS = signal Sniff_receive.receive(p_msgForIDS, call Packet.getPayload(p_msgForIDS, len), len);
		
	}


	event message_t * Lower_ChangePL_Receive.receive(message_t *msg, void *payload, uint8_t len){
		
		//Pass copy of message to IDS
		passToIDS(msg, payload, len);
		
		return signal ChangePL_Receive.receive(msg, payload, len);
	}

	event message_t * Lower_IDS_Receive.receive(message_t *msg, void *payload, uint8_t len){
		
		//Pass copy of message to IDS
		passToIDS(msg, payload, len);
		
		return signal IDS_Receive.receive(msg, payload, len);
	}


	event message_t * Lower_PL_Receive.receive(message_t *msg, void *payload, uint8_t len){
		
		return signal PL_Receive.receive(msg, payload, len);
	}
}
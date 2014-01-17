module DispatcherP{
	uses {
		interface Receive as Lower_PL_Receive;
		interface Receive as Lower_ChangePL_Receive;
		interface Receive as Lower_IDS_Receive;	
		interface Packet;
		interface Init as CryptoCInit;	
		interface Init as PrivacyCInit;	
		interface Init as SharedDataCInit;	
		interface Init as ForwarderCInit;
		interface Init as PrivacyLevelCInit;
		
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
	
	uint8_t m_state = STATE_INIT;
	
	

	command error_t Init.init()
	{
		switch (m_state) {
			case STATE_INIT:
			{
				//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!USE software init and booted interface to signal to dispatcher
				//self init
				p_msgForIDS = &memoryMsgForIDS;	
				
				//init shared data
				call SharedDataCInit.init();
				//crypto init
				call CryptoCInit.init();
				//privacy init
				call PrivacyCInit.init();  //mem init
				//Forwarder init
				call ForwarderCInit.init(); //mem init
				//PrivacyLevel init
				call PrivacyLevelCInit.init(); //nothing in it now
				//additional inits?
				//TODO
				
				//start radio
				//TODO
				
				break;
				}
			case STATE_READY_TO_DEPLOY:
			{
				break;
				}
			
		}
		
		
		
		
		
		
		
		
		
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
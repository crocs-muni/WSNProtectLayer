#define __MSG_VERSION__ 1

typedef nx_struct CardDetectionMsg {
	//protocol version
	nx_uint8_t version;	

	
	nx_uint16_t nodeid;
	
	nx_uint8_t card_number[10];
} CardDetectionMsg;

module MainAppP{
	uses interface Boot;
	uses interface Leds;
	uses interface GeneralRFIDI as Reader;
	
	//uses interface Timer<TMilli> as Timer0;
	
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMC;
}
implementation{
	message_t packet;
	bool sendingMsg = FALSE;	

	task void SendData(){
		if(!sendingMsg){
			//call Leds.led0Toggle();
			
			CardDetectionMsg *msg = (CardDetectionMsg *)(call Packet.getPayload(&packet, sizeof(CardDetectionMsg)));
			
			if(msg != NULL){
				msg->version = __MSG_VERSION__;
				msg->nodeid = TOS_NODE_ID;
				memcpy(msg->card_number, call Reader.getData(), 10);
		
				//send message
				if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(CardDetectionMsg)) == SUCCESS){
					sendingMsg = TRUE;
					//call Leds.led0Toggle();
				}
			}
		}	
	}

	event void Boot.booted(){
		call Reader.init();
		
		call AMC.start();
		
		//call Sensor.init();
		//call Timer0.startPeriodic(REFRESH_INTERVAL);
		
	}
	
	event void Reader.cardDetected(){
		//call Leds.led2On();
		
		post SendData();
	}
	
	event void AMC.stopDone(error_t error){}
	
	event void AMC.startDone(error_t error){	
		if(error == SUCCESS){

		
		}
		else
			call AMC.start();			
	}
	
	event void AMSend.sendDone(message_t *msg, error_t error){
		if(msg == &packet){
			sendingMsg = FALSE;
		}
	}
	
	
	
	
	/*event void Timer0.fired(){

	}*/	
}
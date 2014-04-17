#include "GeneralMotionSensors.h"
#include "MessageStruct.h"
#include "EchoMsgStruct.h"
#include "AM.h"


#define REFRESH_INTERVAL 333
//309


module MainAppP{
	uses interface Boot;
	uses interface GeneralMotionSensorsI as Sensor;
	uses interface Leds;
	
	uses interface Timer<TMilli> as Timer0;
	
	uses interface AMSend as SSend;
	uses interface Receive as SReceive;
	uses interface SplitControl as AMC;

	uses interface Receive as RReceive;
	uses interface SplitControl as Radio;
	
	uses interface CC2420Packet;
	
	uses interface Queue<message_t *> as UARTQueue;
	uses interface Pool<message_t> as UARTPool;
}
implementation{
	void sendMessage(uint8_t operation, uint16_t rssi, uint8_t payload);
	void sendInitMessage();
	task void sendMessageTask();
	
	message_t packet;
	bool UARTBusy = FALSE;

	event void Boot.booted(){
		call AMC.start();
		call Radio.start();
	}

	event void AMC.stopDone(error_t error){}	
	event void AMC.startDone(error_t error){	
		if(error == SUCCESS){
			call Sensor.init();
			call Timer0.startPeriodic(REFRESH_INTERVAL);
		
		}
		else
			call AMC.start();			
	}
	
	task void sendMessageTask(){
		message_t * msg = NULL;
		if(NULL == (msg = call UARTQueue.dequeue())){
			return;
		}
		
		memcpy(&packet, msg, sizeof(message_t));
			
		//free memory	
		if(SUCCESS != call UARTPool.put(msg)){
			return; 
		}	
		
		if(call SSend.send(AM_BROADCAST_ADDR, &packet, sizeof(MotionDetectionMsg)) == SUCCESS){
			UARTBusy = TRUE;
		}
	}

	void sendMessage(uint8_t operation, uint16_t rssi, uint8_t payload){
		message_t * newMsg = NULL;
		MotionDetectionMsg *msg = NULL;
		
		//get space for new mwssage in queue
		if(NULL == (newMsg = call UARTPool.get())){
			return;
		}
		
		if(NULL == (msg = (MotionDetectionMsg *)call SSend.getPayload(newMsg, sizeof(MotionDetectionMsg)))){
			return;
		}		
		
		//load data into message
		msg->version = AM_MSG_VERSION;
		msg->nodeid = TOS_NODE_ID;
		msg->operation = operation;
		msg->rssi = rssi;		
		msg->dataPayload[0] = payload;
		
		//enqueue new message
		if(SUCCESS != call UARTQueue.enqueue(newMsg)){
			call UARTPool.put(newMsg);
			return;
		}
		
		if(!UARTBusy){
			post sendMessageTask();		
		}
	}

	void sendInitMessage(){
		//flush queue
		while(!call UARTQueue.empty()){
			call UARTPool.put(call UARTQueue.dequeue());
		}
		
		sendMessage(MSG_ACK, AM_RSSI_INVALID, MSG_CHECK_MSG);
	}	
	
	//serial send finished
	event void SSend.sendDone(message_t *msg, error_t error){
		//if(msg == &packet){
			UARTBusy = FALSE;
		//}
		if(!call UARTQueue.empty())
			post sendMessageTask();
	}
	
	//MESSAGE RECEIVER
	event message_t * SReceive.receive(message_t *msg, void *payload, uint8_t len){
		MotionDetectionMsg *rmsg = (MotionDetectionMsg *)payload;
		
		if(rmsg->version == AM_MSG_VERSION){
			if(rmsg->operation == MSG_CHECK_MSG){
				call Leds.led1On();
				sendInitMessage();
			}
		}
		
		return msg;
	}
	
	//SCAN DONE EVENT
	event void Sensor.scanDone(uint8_t response){		
		if(response == GMSI_MOVE_DETECTED){
			//detected movement (red led)
			sendMessage(MSG_MOVEMENT_DETECTED, AM_RSSI_INVALID, 0);
			call Leds.led0On();
			call Leds.led1Off();
			call Leds.led2Off();
		}
		else if(response == GMSI_NO_MOVE_DETECTED){
			//no movement (green led)
			call Leds.led1On();
			call Leds.led2Off();
			call Leds.led0Off();
		}
		else if(response == GMSI_SENSOR_NOT_READY){
			//sensor is not stabilized
			call Leds.led1Off();
			call Leds.led0Off();
			call Leds.led2On();
		}
		/*else {
			call Leds.led0On();
			call Leds.led1On();
			call Leds.led2On();
			sendMessage(MSG_MOVEMENT_DETECTED, response);
		}*/
	}
	
	
	event void Timer0.fired(){
		if(!call Sensor.isScanning()){
			call Sensor.scan();
		}
	}	

	event message_t * RReceive.receive(message_t *msg, void *payload, uint8_t len){
		EchoMsg *rmsg = (EchoMsg *)payload;
		int8_t rssi = 0;

		if(rmsg->version == AM_ECHO_VERSION){
			rssi = call CC2420Packet.getRssi(msg);
			sendMessage(MSG_ECHO_DETECTED, rssi, (uint8_t)rmsg->nodeid);
		}
		
		return msg;
	}
	
	event void Radio.startDone(error_t error){}
	event void Radio.stopDone(error_t error){}
}
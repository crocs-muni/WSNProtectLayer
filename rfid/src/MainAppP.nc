#include "GeneralMotionSensors.h"

#define REFRESH_INTERVAL 309

#define __MSG_VERSION__ 1
typedef nx_struct MotionDetectionMsg {
	//protocol version
	nx_uint8_t version;	

	
	nx_uint16_t nodeid;
	
	nx_uint8_t motionStatus;
}MotionDetectionMsg;

module MainAppP{
	uses interface Boot;
	uses interface GeneralMotionSensorsI as Sensor;
	uses interface Leds;
	
	uses interface Timer<TMilli> as Timer0;
	
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMC;
}
implementation{
	message_t packet;
	bool sendingMsg = FALSE;	

	/*task void SendData(){
		if(!sendingMsg){
			//call Leds.led0Toggle();
			
			MotionDetectionMsg *msg = (MotionDetectionMsg *)(call Packet.getPayload(&packet, sizeof(MotionDetectionMsg)));
			
			if(msg != NULL){
				msg->version = __MSG_VERSION__;
				msg->nodeid = TOS_NODE_ID;
				msg->motionStatus = 0xFF;
		
				//send message
				if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(MotionDetectionMsg)) == SUCCESS){
					sendingMsg = TRUE;
					call Leds.led0Toggle();
				}
			}
		}	
	}*/

	event void Boot.booted(){
		//call Leds.led1Toggle();
		call AMC.start();
		//call Sensor.init();
		//call Timer0.startPeriodic(REFRESH_INTERVAL);
	}
	
	event void AMC.stopDone(error_t error){}
	
	event void AMC.startDone(error_t error){	
		if(error == SUCCESS){
			call Sensor.init();
			call Timer0.startPeriodic(REFRESH_INTERVAL);
			//post SendData();
		
		}
		else
			call AMC.start();			
	}
	
	event void AMSend.sendDone(message_t *msg, error_t error){
		if(msg == &packet){
			sendingMsg = FALSE;
			//call Leds.led0Toggle();
		}
	}
	
	
	event void Sensor.scanDone(uint8_t response){
		if(!sendingMsg && response == GMSI_MOVE_DETECTED){
			//call Leds.led0Toggle();
			
			MotionDetectionMsg *msg = (MotionDetectionMsg *)(call Packet.getPayload(&packet, sizeof(MotionDetectionMsg)));
			
			if(msg != NULL){
				msg->version = __MSG_VERSION__;
				msg->nodeid = TOS_NODE_ID;
				msg->motionStatus = response;
		
				//send message
				if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(MotionDetectionMsg)) == SUCCESS){
					sendingMsg = TRUE;
					//call Leds.led0Toggle();
				}
			}
		}
			
		if(response == GMSI_MOVE_DETECTED){
			//detected movement (blue led)
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
		else {
			call Leds.led0On();
			call Leds.led1On();
			call Leds.led2On();
		}
		
		if(!call Sensor.isSuspended()){
			//call Sensor.suspend();
		}
	}
	
	
	event void Timer0.fired(){
		if(call Sensor.isSuspended()){
			call Sensor.wakeUp();
			while(call Sensor.isSuspended());
		}
		if(!call Sensor.isScanning()){
			call Sensor.scan();
		}
		
		//post SendData();
		//call Leds.led1Toggle();
	}	
}
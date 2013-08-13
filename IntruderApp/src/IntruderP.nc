/**
 * Module for signaling the Intruder presence.
 * 
 * @author Filip Jurnecka 
 */

#include "../../ProtectLayer/src/ProtectLayerGlobals.h"
#include "printf.h"
module IntruderP {
	provides {
		interface Init;
	}
	uses {
		interface SplitControl as RadioControl; 
		
		interface AMSend;
	    interface Packet;
	    interface AMPacket;
	    interface PacketAcknowledgements as Acks;
	    
	    interface Timer<TMilli> as Timer;
	    
	    interface Leds;
	}
}

implementation {
	/** flag signaling whether the serial port is busy */ 
	bool radioBusy = FALSE;

	message_t packet;
	
	command error_t Init.init() {
		radioBusy = TRUE;
		if (call RadioControl.start() != SUCCESS) {
			return FAIL;
   		}
		// Start movement event simulation every 3.5 time interval
		call Timer.startPeriodic(POLICEMAN_TIMER_MESSAGE_MILLI); 
		return SUCCESS;
	}
	
	event void Timer.fired() { 
		if (!radioBusy)
	    {
	    	intrusion_msg_t * intrMsg = (intrusion_msg_t * ) call Packet.getPayload(&packet,
					sizeof(intrusion_msg_t));

			if(intrMsg == NULL) {
				return;
			}
			if(call Packet.maxPayloadLength() < sizeof(intrusion_msg_t)) {
				return;
			}
			intrMsg->rssi = -55;
			if(call AMSend.send(AM_BROADCAST_ADDR, &packet,
					(uint8_t) sizeof(intrusion_msg_t)) == SUCCESS) {
				radioBusy = TRUE;
			}
	    }
	}

	event void AMSend.sendDone(message_t *msg, error_t error){
		//call Leds.led0Toggle();
		radioBusy = FALSE;
		if (error == SUCCESS) {
			call Leds.led0Toggle();
		} else {
			call Leds.led2Toggle();
		}
	}

	event void RadioControl.startDone(error_t error){
		if (error != SUCCESS) {
			call Leds.led0On();
			call Leds.led2On();
		} else {
			radioBusy = FALSE;
		}
	}
	
	event void RadioControl.stopDone(error_t error){
	}
}

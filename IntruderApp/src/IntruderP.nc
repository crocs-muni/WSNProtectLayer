/**
 * Module for signaling the Intruder presence.
 * 
 * @author Filip Jurnecka 
 */

#include "IntruderApp.h"
#include "../../ProtectLayer/src/ProtectLayerGlobals.h"
#include <UserButton.h>
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

		interface Get<button_state_t>;
		interface Notify<button_state_t>;
		interface Timer<TMilli> as Timer;

		interface Leds;
	}
}

implementation {
	/** flag signaling whether the serial port is busy */
	bool radioBusy = FALSE;
	uint8_t intruderState = STATE_PASSIVE;
	message_t packet;

	command error_t Init.init() {
		radioBusy = TRUE;
		if(call RadioControl.start() != SUCCESS) {
			return FAIL;
		}
		call Notify.enable();
		call Leds.led2On();
		return SUCCESS;
	}

	event void Notify.notify(button_state_t state) {
		if ( state == BUTTON_PRESSED ) {
			call Timer.stop();			
			if(intruderState == STATE_PASSIVE) {
				intruderState = STATE_MSN;
				call Leds.led2Off();
				call Leds.led1On();
				
				// Start movement event simulation every 3.5 time interval
				call Timer.startOneShot(POLICEMAN_TIMER_MESSAGE_MILLI);
			} else if (intruderState == STATE_MSN) {
				intruderState = STATE_INTRUDER;
				call Leds.led1Off();
				call Leds.led0On();
				
				call Timer.startOneShot(POLICEMAN_TIMER_MESSAGE_MILLI);
			} else {
				intruderState = STATE_PASSIVE;
				call Leds.led0Off();
				call Leds.led2On();
			}
		}
	}

	event void Timer.fired() {
		if( ! radioBusy) {
			intrusion_msg_t * intrMsg = (intrusion_msg_t * ) call Packet.getPayload(
					&packet, sizeof(intrusion_msg_t));

			if(intrMsg == NULL) {
				return;
			}
			if(call Packet.maxPayloadLength() < sizeof(intrusion_msg_t)) {
				return;
			}
			intrMsg->rssi = -55;
			if(intruderState == STATE_MSN) {
				intrMsg->isIntruder = FALSE;
			}
			else {
				intrMsg->isIntruder = TRUE;
			}
			if(call AMSend.send(AM_BROADCAST_ADDR, &packet,
					(uint8_t) sizeof(intrusion_msg_t)) == SUCCESS) {
				radioBusy = TRUE;
			}
		}
	}

	event void AMSend.sendDone(message_t * msg, error_t error) {
		//call Leds.led0Toggle();
		radioBusy = FALSE;
		call Timer.startOneShot(POLICEMAN_TIMER_MESSAGE_MILLI);
		if(error == SUCCESS) {
			call Leds.led2Toggle();
		}
		else {
			call Leds.led0On();
		}
	}

	event void RadioControl.startDone(error_t error) {
		if(error != SUCCESS) {
			call Leds.led0On();
			call Leds.led2On();
		}
		else {
			radioBusy = FALSE;
		}
	}

	event void RadioControl.stopDone(error_t error) {
	}
}
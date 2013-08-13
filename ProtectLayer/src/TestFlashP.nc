/**
 * 
 * @author Filip Jurnecka
 */

#include "ProtectLayerGlobals.h"
module TestFlashP {
	provides {
		interface Init;
	}
	uses {
		interface SplitControl as SerialControl;

		interface Receive as FlashGet;
		interface Receive as FlashSet;
		interface Packet;
		interface PacketAcknowledgements as Acks;

		interface Leds;
		
		interface ResourceArbiter as Flash;
		
		interface Configuration;
		
		interface Logger;
	}
}

implementation {

	/** 
	 * Start the radio and serial ports when booting 
	 */
	command error_t Init.init() {
		if(call SerialControl.start() != SUCCESS) 
			return FAIL;
		return SUCCESS;
	}

	/** 
	 * Notify caller that the component has been started and is ready to
	 * receive other commands.
	 *
	 * @param <b>error</b> -- SUCCESS if the component was successfully
	 *                        turned on, FAIL otherwise
	 */
	event void SerialControl.startDone(error_t error) {
		if(error != SUCCESS) {
			call Leds.led0On();
			call Leds.led1On();
		}
	}

	/**
	 * Notify caller that the component has been stopped.
	 *
	 * @param <b>error</b> -- SUCCESS if the component was successfully
	 *                        turned off, FAIL otherwise
	 */
	event void SerialControl.stopDone(error_t error) {
	}

	/**
	 * Restores combinedData from flash memory and returns them via serial 
	 * 
	 * @param msg Expects a translated SavedDataMsg
	 * @param  'void* COUNT(len) payload'  a pointer to the packet's payload
	 * @param  len      the length of the data region pointed to by payload
	 * @return the incoming message msg 
	 */
	event message_t * FlashGet.receive(message_t * msg, void * payload,
			uint8_t len) {		
			//message_t packet;			
		if(len == sizeof(flash_get_msg_t)) {
			//TODO vylepsit tim, ze predelam vstupni parametr loggeru na nejaky retezec ZEPTAT SE PETRA
			//log_msg_t* testMsg = (log_msg_t*)call Packet.getPayload(&packet, sizeof(log_msg_t));
			//testMsg -> counter = 100; 
			//call Logger.logToPC(&packet, sizeof(log_msg_t));
			call Flash.restoreFromFlash();			
		}
		return msg;
	}
	
	/**
	 * Saves combinedData to flash memory and returns them via serial
	 * 
	 * @param msg Expects a translated SavedDataMsg
	 * @param  'void* COUNT(len) payload'  a pointer to the packet's payload
	 * @param  len      the length of the data region pointed to by payload
	 * @return the incoming message msg 
	 */
	event message_t * FlashSet.receive(message_t * msg, void * payload,
			uint8_t len) {
		if(len == sizeof(flash_set_msg_t)) {
			call Flash.backupToFlash();
		}
		return msg;
	}

	event void Flash.backupToFlashDone(error_t result){
		call Leds.led0Off();
		if (result == SUCCESS) {
			call Configuration.signalConfSend();
		} else {
			call Leds.led0On();
		}
	}

	event void Flash.restoreFromFlashDone(error_t result){
		call Leds.led0Off();
		if (result == SUCCESS) {
			call Configuration.signalConfSend();
		} else {
			call Leds.led0On();
		}
	}

	event void Configuration.signalConfSendDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void Logger.logToPCDone(message_t *msg, error_t error){
		call Leds.led2On();
	}
}

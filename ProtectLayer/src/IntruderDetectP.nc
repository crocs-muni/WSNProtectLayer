#include "ProtectLayerGlobals.h"
#include "printf.h"

module IntruderDetectP {
	provides {
		interface MovementSensor;
	}
	uses {
		interface Receive;
		interface CC2420Packet;
		interface Leds;
	}
}
implementation {
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		intrusion_msg_t * intrMsg = (intrusion_msg_t * ) payload;
		if (call CC2420Packet.getRssi(msg) - 45 > intrMsg->rssi)
			signal MovementSensor.movementDetected();
		return msg;
	}
}

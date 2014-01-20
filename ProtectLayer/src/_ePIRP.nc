#include "ProtectLayerGlobals.h"
module ePIRP {
	provides {
		interface MovementSensor;
		interface Init;
	}
	uses interface Timer<TMilli> as Timer0;
}
implementation {
	command error_t Init.init() {
		// Start movement event simulation every 3.5 time interval
		call Timer0.startPeriodic(3 * POLICEMAN_TIMER_MESSAGE_MILLI + POLICEMAN_TIMER_MESSAGE_MILLI / 2); 
		return SUCCESS;
	}
	event void Timer0.fired() { 
		signal MovementSensor.movementDetected();
	}
}

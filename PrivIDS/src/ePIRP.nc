#include "ProtectLayerGlobals.h"
#include "printf.h"
module ePIRP {
	provides {
		interface MovementSensor;
		interface Init;
		
	}
	uses {
		interface Timer<TMilli> as Timer0;
		interface ParameterInit<uint16_t> as RandomInit;	
		interface Random;
		interface Stats;
		interface Leds;
	}
}
implementation {
	
	uint8_t m_movementCounter=0;
	

	command error_t Init.init() {
		uint16_t delay;
		dbg("SimulationLog", "ePIR initialized\n");
		m_movementCounter=0;
		
		call RandomInit.init(TOS_NODE_ID);
		delay = call Random.rand16() % 10000;
		call Timer0.startPeriodic(EXPERIMENT_EVENT_PERIOD); 
		return SUCCESS;
	}
	event void Timer0.fired() { 
	
		if (m_movementCounter < EXPERIMENT_MOVEMENT_COUNT)
		{
			m_movementCounter++;		
			call Stats.eventSensed();
			call Leds.led1Toggle();
//			printf("event led toggled \n");
//			printfflush();
			signal MovementSensor.movementDetected();
		} else
		{
			call Timer0.stop();
		}	
	}
}

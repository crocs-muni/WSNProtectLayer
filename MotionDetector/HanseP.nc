#include "GeneralMotionSensors.h"

//#define __MSP430_HAS_PORT6_R__
#define CHECK_INTERVAL 80

module HanseP{
	provides interface GeneralMotionSensorsI as GMSI;
	//pins interfaces
	uses interface HplMsp430GeneralIO as GND;
	uses interface HplMsp430GeneralIO as SENSE;
	uses interface Timer<TMilli> as Timer0;
}
implementation{
	uint8_t m_data;
	bool m_scanning;
	bool m_suspend;
	
	task void scanDone(){
		atomic {
			signal GMSI.scanDone(m_data);
			m_data = GMSI_NO_MOVE_DETECTED;
			m_scanning = FALSE;
		}	
	}
	
	event void Timer0.fired(){
		//if motion is detected, then m_data will be set to
		//GMSI_MOVE_DETECTED and will remain in this state
		//until first read ( = scan is called)
		atomic if(!call SENSE.get())
			m_data = GMSI_MOVE_DETECTED;	
	}
	
	
	async command void GMSI.init(){
		atomic m_scanning = FALSE;
		atomic m_suspend = FALSE;
		//initial state
		atomic m_data = GMSI_NO_MOVE_DETECTED;
		//set ADC0 as output, and connect it to the ground (this enables sensor)
		call GND.selectIOFunc();
		call GND.makeOutput();
		call GND.clr();
		
		//set ADC1 as input with enabled pullup resistor
		call SENSE.selectIOFunc();
		call SENSE.makeInput();
		//it seems like MSP430F1611 doesn't have pullup/down resistors..
		/*if(EINVAL == call SENSE.setResistor(MSP430_PORT_RESISTOR_PULLUP)){
			atomic m_data = GMSI_SENSOR_NOT_READY;
		}*/
		
		//start periodic check
		call Timer0.startPeriodic(CHECK_INTERVAL);
	}
	
	async command void GMSI.suspend(){
		call GND.set();
		atomic m_suspend = TRUE;
		
		if(call Timer0.isRunning())
			call Timer0.stop();
	}
	
	async command bool GMSI.isSuspended(){
		atomic return m_suspend;
	}
	
	async command void GMSI.wakeUp(){
		call GND.clr();
		atomic m_suspend = FALSE;
		
		if(!call Timer0.isRunning())
			call Timer0.startPeriodic(CHECK_INTERVAL);
	}
	
	async command void GMSI.scan(){
		atomic m_scanning = TRUE;
		
		/*if(!call SENSE.get())
			atomic m_data = GMSI_MOVE_DETECTED;
		else
			atomic m_data = GMSI_NO_MOVE_DETECTED;*/
			
		post scanDone();
	}
	
	async command bool GMSI.isScanning(){
		atomic return m_scanning;
	}
}
#include "Serial.h"
#include "Zilog.h"
#include "GeneralMotionSensors.h"

module ZilogP @safe() {
	provides interface GeneralMotionSensorsI as GMSI;
	
	//uart interface
	uses interface HplMsp430Usart as Usart0;
	uses interface Resource as Usart0Res;
	
	//internal commands
	//provides async command void sendZilogCmd(uint8_t data);
	//provides async command uint8_t getZilogResponse();
}
implementation{
	uint8_t m_data;
	bool 	m_suspend;
	bool 	m_scanning;
	uint8_t m_currentState;
	uint8_t m_dummy_counter = 0;

	/**
	 * this task compare ZILOG response and sends corresponding response
	 * and emit scanDone event with this response
	 */

	task void emitDone(){
		uint8_t response = 0;
		
		atomic switch (m_data){
			//movement detected
			case READ_MS_Y:	response = GMSI_MOVE_DETECTED;
							break;
			//no moves			
			case READ_MS_N:	response = GMSI_NO_MOVE_DETECTED;
							break;
			//ePIR is not stabilized				
			case READ_MS_U:	response = GMSI_SENSOR_NOT_READY;
							break;
							
			case CMD_ACK:	response = GMSI_ACK;
							break;
							
			case CMD_NACK:	response = GMSI_NACK;
							break;
			//unknown response, send received data
			default: 		response = m_data;
							break; 
		};
		
		//scan is complete
		atomic m_scanning = FALSE;
		atomic signal GMSI.scanDone(response);
		//dummy blinking
		//atomic signal GMSI.scanDone(GMSI_MOVE_DETECTED);
		
		//call GMSI.suspend();
	}	

	/**
	 * function sends command to zilog's serial interface
	 */
	void sendZilogCmd(uint8_t data){
		call Usart0.tx(data);
		
		while(!call Usart0.isTxEmpty());
		if(call Usart0.isTxIntrPending()){
			call Usart0.clrTxIntr();
		}
	}
	
	/**
	 * function reads response from zilog
	 * @return	Received data
	 */
	uint8_t getZilogResponse(){
		while(!call Usart0.isRxIntrPending());
		return call Usart0.rx();
		//dummy
		/*if(m_dummy_counter++ % 6 == 0)
			return GMSI_MOVE_DETECTED;
			
		return GMSI_NO_MOVE_DETECTED;*/
	}
	
	///////////////////////////////////////////////////////////////////
	
	/**
	 * Do not forget wait at least 20s until ePIR sensor is stabilized.
	 */
	async command void GMSI.init(){
		atomic {
			m_scanning = FALSE;
			m_suspend = FALSE;
			m_currentState = S_IDLE;
			
			//try to wake up
			call GMSI.wakeUp();
		}
	}
	
	/**
	 * Suspend will reduce power consumption, but you have to
	 * wait after wake up until ePIR sensor is stabilized again. 
	 */	
	async command void GMSI.suspend() {		
		atomic if(m_currentState == S_IDLE){
			m_currentState = S_SUSPEND_REQUEST;
		}
		call Usart0Res.request();
	}
	
	async command bool GMSI.isSuspended(){
		atomic return m_suspend;
	}
	
	async command void GMSI.wakeUp(){		
		atomic m_currentState = S_WAKEUP_REQUEST;
			
		call Usart0Res.request();
	}
	
	async command void GMSI.scan(){
		atomic if(m_currentState == S_IDLE){
			//change state to scan request
			m_scanning = TRUE;
			m_currentState = S_SCAN_REQUEST;		
		}
		//request foŕ resource
		call Usart0Res.request();
	}
	
	async command bool GMSI.isScanning(){
		atomic return m_scanning;	
	}
	
	/**
	 * puts zilog into sleep mode
	 */
	void goSleepCmd(){
		//suspend driving			
			
		sendZilogCmd(SLEEP_MODE);
		if(CMD_ACK == getZilogResponse()){
			//confirmation
			sendZilogCmd('1');
			sendZilogCmd('2');
			sendZilogCmd('3');
			sendZilogCmd('4');
			//read (ACK/NACK)
			if(getZilogResponse() == CMD_ACK){
				atomic m_suspend = TRUE;
				//call Leds.led2On();
			}
			else {
				atomic m_suspend = FALSE;
			}
		}
		else {
			atomic m_suspend = FALSE;
		}
	}
	
	/**
	 * wake up zilog from sleep mode
	 */
	void wakeUpCmd(){
		sendZilogCmd(READ_MOTION_STATUS);
		//call Leds.led2Off();
	}
	
	/////////////////////////////////////////////////////////////
	event void Usart0Res.granted(){
		//int i;
		uint8_t state; atomic state = m_currentState;
		
		//setup USART0 8N1 9600Baud
		call Usart0.setModeUart(&uart9600);
		call Usart0.enableUart();

			
		//resource granted
		if(state == S_SCAN_REQUEST){
			/*atomic {
				if(m_suspend == TRUE)
					wakeUpCmd();
			}*/
			atomic {
			//check motion state
				sendZilogCmd(READ_MOTION_STATUS);
				m_data = getZilogResponse();
			}
			
			post emitDone();
			//goSleepCmd();
		}
		else if(state == S_SUSPEND_REQUEST){
			goSleepCmd();
		}
		else if(state == S_WAKEUP_REQUEST){
			//this command just wake up sensor
			wakeUpCmd();
		}
	
		//go back to idle state, and release all granted resources
		atomic m_currentState = S_IDLE;
		call Usart0Res.release();
	}
	
}
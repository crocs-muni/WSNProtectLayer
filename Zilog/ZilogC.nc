/* Implementation of..
 * Author: Bc. Marcel Gazdik <xgazdi at mail.muni.cz>
 */

//#include "Timer.h"
#include <stdio.h>
#include <stdarg.h>
#include "Zilog.h"

	static inline void Debug(const char *str, ...){
#ifdef DEBUG
		va_list ap;
		va_start(ap, str);
		vprintf(str, ap);
		va_end(ap);
#else

#endif
	}

module ZilogC{
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> 	as Timer0;
	uses interface HplMsp430Usart 	as Uart0;
	uses interface Resource 	as Uart0Resource; 
	
	
	provides command void checkMotion();
	provides command void sendUartCmd(uint8_t cmd);
	provides command uint8_t getUartResponse();
}

implementation{
	uint8_t ePIRStabDelay = 100;


	task void toggleLed(){
		//call checkMotion();
	}

	command void sendUartCmd(uint8_t cmd){
		call Uart0.tx(cmd);

		//wait until tx buffer is empty
		while(! call Uart0.isTxEmpty());
		if(call Uart0.isTxIntrPending()){
			call Uart0.clrTxIntr();
		}
	}
	
	command uint8_t getUartResponse(){
		//wait until reciev is done
		while(! call Uart0.isRxIntrPending());
		return call Uart0.rx();
	}

	command void checkMotion(){
		uint8_t data = 0;
		
		//wake up Mr. Freeman! (this command will be ignored if sensors is in sleep mode)
		//call sendUartCmd(READ_MOTION_STATUS);

		//send command a (check if there was a movement)
		call sendUartCmd(READ_MOTION_STATUS);

		//get the response from zilog
		data = call getUartResponse();


		Debug("Response to cmd 0x61: %c\n", (char)data);

		/*//go to sleep (dummy read and confirmation)
		call sendUartCmd(SLEEP_MODE);
		call getUartResponse();
		//confirmation
		call sendUartCmd('1');
		call sendUartCmd('2');
		call sendUartCmd('3');
		call sendUartCmd('4');
		//dummy read (ACK/NACK)
		call getUartResponse();*/

		if(data == READ_MS_Y){
			//detected movement (blue led)
			call Leds.led2On();
			call Leds.led1Off();
			call Leds.led0Off();
		}
		else if(data == READ_MS_N){
			//no movement (green led)
			call Leds.led1On();
			call Leds.led2Off();
			call Leds.led0Off();
		}
		else {
			//ok there has to be an error (prehaps sensor is not present?)
			call Leds.led1Off();
			call Leds.led2Off();
			call Leds.led0On();
		}
	}

	event void Boot.booted() {
		//20s delay counter
		ePIRStabDelay = (20*1024)/LOAD_INTERVAL;


		//load blink interval
		call Timer0.startPeriodic(LOAD_INTERVAL);
		while (call Uart0Resource.request() != SUCCESS);
		Debug("Wait 20s for ePIR stabilization\n");
	}


	event void Timer0.fired(){
		//wait 20s for ePIR stabilisation
		uint8_t r = ePIRStabDelay % 3;
		if(ePIRStabDelay > 1){
			//loading led bar
			if(r == 0){
				call Leds.led0On();
				call Leds.led1Off();	
			} else if(r == 1) {
				call Leds.led1On();
				call Leds.led2Off();	
			}
			else {
				call Leds.led2On();
				call Leds.led0Off();
			}	

			ePIRStabDelay--;
			return; 
		}
		else if(ePIRStabDelay == 1){
			//disable loading led bar and enable periodic measurement
			call Timer0.stop();
			call Timer0.startPeriodic(MEASURE_INTERVAL);
			ePIRStabDelay--;
			Debug("ePIR should be initialized, begining movement checking\n");
		}
		
		post toggleLed();
		call checkMotion();		
	}

	event void Uart0Resource.granted(){
		msp430_uart_union_config_t uart9600 = { 
  			{
      				utxe : 1,
      				urxe : 1, 
      				ubr : UBR_1MHZ_9600, 
      				umctl : UMCTL_1MHZ_9600, 
      				ssel : 0x02, 
      				pena : 0, 
      				pev : 0, 
      				spb : 0, 
      				clen : 1, 
      				listen : 0, 
      				mm : 0, 
      				ckpl : 0, 
      				urxse : 0, 
      				urxeie : 1, 
      				urxwie : 0,
      				utxe : 1,
      				urxe : 1
  			} 
		};

		call Uart0.setModeUart(&uart9600);
		call Uart0.enableUart();

		Debug("USART0 init, DONE\n");
	}
} 

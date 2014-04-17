#include "Uart.h"


module ElBrick125P @safe() {
	provides interface GeneralRFIDI as GRFIDI;
      
    uses interface HplMsp430Usart as Usart0;
    uses interface HplMsp430UsartInterrupts as Usart0Int;
    uses interface HplMsp430GeneralIO as SENSE;
    uses interface Resource as Usart0Res;
      
    uses interface Timer<TMilli> as Timer0;
      
    uses interface Leds;
    
    provides async command void releaseUsart();
}

implementation {
    bool uartGranted;
    bool pendingRead;
    
    uint8_t cardNumber[10] = {0};
    uint8_t parity[2] = {0};
	uint8_t byteCounter = 0;
    
    //start timer
    task void startTimer(){
    	
    	call Timer0.startPeriodic(137);
    }
    
    //emit signal about new card detection
    task void emitDoneSignal(){
    	atomic signal GRFIDI.cardDetected(); 
    }
      
    async command void GRFIDI.init(){
    	atomic {
      		uartGranted = FALSE;
      		pendingRead = FALSE;
      	
      		call SENSE.selectIOFunc();
			call SENSE.makeOutput();
			call SENSE.clr();
      		
      		call GRFIDI.wake();
      	} 
      	post startTimer();
      	
      	/*call SENSE.selectIOFunc();
		call SENSE.makeOutput();
		call SENSE.clr();
      	//call GRFIDI.wake();
      	//call GRFIDI.sleep();*/
      	
    }
    
    /**
     * release Usart source and sets all necessary variables
     * to default value
     */
    async command void releaseUsart(){
    	call Usart0Res.release();
    	atomic {	
      		uartGranted = FALSE;
      		pendingRead = FALSE;
      		byteCounter = 0;
      	}
      	
      	call Leds.led0Off();
      	call Leds.led1Off();
    }
    
    event void Timer0.fired(){
      	atomic {
      		if(!uartGranted){
      			call Usart0Res.request();
      		}
      		else if(uartGranted && !pendingRead){
				//release uart if nothing was detected
      			call releaseUsart();
      		}
      	}
    }
      
    /**
     * ElBrick125 doesn't support data receiving while running in UART mode
     *
     * return FALSE (ALWAYS)
     */ 
    async command bool GRFIDI.sendData(uint8_t data){
		return FALSE;
    }
      
    async command uint8_t * GRFIDI.getData(){
		return cardNumber;
    }
    
	//not needed
    async event void Usart0Int.txDone(){}
    ////////////
    
    
    /**
     * read all 14 bytes and compute check checksums, if 
     * everything is ok, then emit cardDetected signal.
     */
    async event void Usart0Int.rxDone(uint8_t data){
    	//call Usart0.clrRxIntr();
    	
    	atomic {
   		 	if(data == 0x02 && byteCounter == 0){
    			//received start byte
    			pendingRead = TRUE;
    			//call Leds.led1On();
    			byteCounter++;
    		}
    		else if(byteCounter > 0 && byteCounter <= 10){
    			//next 10 bytes are card code (Card ID)
    			cardNumber[byteCounter - 1] = data;
    			byteCounter++;
    		}
    		else if(byteCounter > 10 && byteCounter <= 12){
	  			//bytes 11 and 12 are checksum code
	  			parity[byteCounter - 11] = data;
  				byteCounter++;  	
    		}
    		else if(data == 0x03 && byteCounter == 13){
    			//stop byte	
    			call releaseUsart();
    			
    			if(call GRFIDI.checkChecksum()){
    				call Leds.led0On();
    			}
    			else {
	    			call Leds.led1On();
	    			post emitDoneSignal();
	    		}
    		}
    		else {
    			//something gone bad    			
    			call releaseUsart();
    			
    			call Leds.led0On(); 
	    		call Leds.led1Off();
    		}
    	}
    	//call Usart0.clrRxIntr();
    }
    
    async command bool GRFIDI.checkChecksum(){
    	uint8_t i = 0;
    	uint8_t sum = 0;
    	
    	//check first 5 bytes
    	sum = cardNumber[0];
    	for(i = 1; i < 5; i++){
    		sum ^= cardNumber[i];	
    	}
    	
    	if(sum != parity[0])
    		return FALSE;
    		
    	//check second half
    	sum = cardNumber[5];
    	for(i = 6; i < 10; i++){
    		sum ^= cardNumber[i];	
    	}
    	
    	if(sum != parity[1])
    		return FALSE;
    	
    	return TRUE;
    }
    
      
    event void Usart0Res.granted(){
    	atomic {
			uartGranted = TRUE;
			byteCounter = 0;
		}     
    	//call Leds.led0On();		 	
		
		call Usart0.setModeUart(&uart9600);
		call Usart0.enableRxIntr();	 
		   
    }

	async command void GRFIDI.sleep(){
		call SENSE.set();
	}

	async command void GRFIDI.wake(){
		call SENSE.clr();
	}
}
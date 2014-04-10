#include "Uart.h"

cofiguration ElBrick125P @safe() {
      provides interface GeneralRFIDI as GRFIDI;
      
      uses interface HplMsp430Usart as Usart0;
      uses interface Resource as Usart0Res;
}

implementation {
      uint16_t m_recievedData;
      
      async command void GRFIDI.init(){
      }
      
      /**
       * ElBrick125 doesn't support data recieving while running in UART mode
       *
       */ 
      async command bool GRFIDI.sendData(uint8_t data){
	      return false;
      }
      
      async command uint16_t GRFIDI.getData(){
      }
      
      event void Usart0Res.granted(){
	      call Usart0.setModeUart(&uart9600);
	      call Usart0Res.relase();
      }
}
#ifndef UART_CONF_H
#define UART_CONF_H

#include "msp430usart.h"

//UART baudrate etc setup
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
      	utxe : 0,
      	urxe : 1
  	} 
};

#endif /* UART_CONF_H */

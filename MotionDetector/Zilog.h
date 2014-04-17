#ifndef ZILOG_H
#define ZILOG_H

#include "msp430usart.h"
//#include "Serial.h"

//commands
#define READ_MOTION_STATUS	0x61
#define SLEEP_MODE 			0x5A

//command response
#define READ_MS_Y		'Y'	//move detected
#define READ_MS_N		'N'	//nothing has been detected
#define READ_MS_U		'U'	//ePIR not stabilized

#define CMD_ACK			0x06
#define CMD_NACK		0x15

//delay intervals etc
#define MEASURE_INTERVAL 	103 //millisecond timer
#define LOAD_INTERVAL 		309 

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
      	utxe : 1,
      	urxe : 1
  	} 
};

enum SCANNING_STATES {
	S_IDLE = 0,
	S_SCAN_REQUEST,
	S_SUSPEND_REQUEST,
	S_WAKEUP_REQUEST
};

#endif /* ZILOG_H */

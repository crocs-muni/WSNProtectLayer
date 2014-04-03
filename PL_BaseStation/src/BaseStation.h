// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

// This is basestation definition fro protect layer
#define THIS_IS_BS
//#define USE_CTP
#define DEBUG_PRINTF

#define ACCEPT_ALL_SIGNATURES
#define ACCEPT_ALL_MACS
#define CTP_QUICK_INIT
#define TOS_BS_NODE_ID TOS_NODE_ID
//#define NO_CRYPTO

#include "../../ProtectLayer/src/ProtectLayerGlobals.h"

#define BS_PRINTF(x) x
#define BS_PRINTFFLUSH() pl_printfflush()

#define HASH_KEYS 10

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 2000,
  TIMER_BLINK_PAUSE = 500,
  TIMER_BLINK_PAUSE_SHORT = 250,
  TIMER_BLINK_COUNT = 10,			// Number of warning blinks before PL change.
  TIMER_BLINK_SUCCESS_COUNT = 2,	// Number of blinks in case of success.
  PLEVEL_MSGS = 3,					// How many PL change packets should be sent in one row.
  PLEVEL_WAIT = 1000				// Pause between two PL change packets.
};

enum {
    UART_QUEUE_LEN = 32,
    RADIO_QUEUE_LEN = 4,
};

// Init state
enum { 
	INIT_STATE_BOOTED = 0,
	INIT_STATE_RUNNING = 1
};

// Sending state
enum {
	SEND_STATE_BLINKING = 0,
	SEND_STATE_SENDING = 1,
	SEND_STATE_SENT = 2,
	SEND_STATE_SIGNALIZE_SUCCESS = 3,
	SEND_STATE_END = 4,
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} BlinkToRadioMsg;

#endif 
// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

// This is basestation definition fro protect layer
#define THIS_IS_BS
#define USE_CTP
#define DEBUG_PRINTF

#define ACCEPT_ALL_SIGNATURES
#define ACCEPT_ALL_MACS
#define CTP_QUICK_INIT

#include "../../ProtectLayer/src/ProtectLayerGlobals.h"

#define BS_PRINTF(x) x
#define BS_PRINTFFLUSH() pl_printfflush()

#define HASH_KEYS 10

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 2000,
  TIMER_BLINK_PAUSE = 500,
  TIMER_BLINK_PAUSE_SHORT = 250,
  TIMER_BLINK_COUNT = 10,
  PLEVEL_MSGS = 3,
  PLEVEL_WAIT = 1000
};

enum {
    UART_QUEUE_LEN = 24,
    RADIO_QUEUE_LEN = 4,
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} BlinkToRadioMsg;

#endif 
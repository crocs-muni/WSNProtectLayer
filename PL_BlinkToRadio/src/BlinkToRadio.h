// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 2000
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} BlinkToRadioMsg;

#define DEBUG_PRINTF
#define USE_CTP
#define CTP_DUMP_NEIGHBORS
#define ACCEPT_ALL_SIGNATURES
#define ACCEPT_ALL_MACS
#define CTP_QUICK_INIT


#endif 
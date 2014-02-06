// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

// This is basestation definition fro protect layer
#define THIS_IS_BS
#include "../../ProtectLayer/src/ProtectLayerGlobals.h"

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 2000
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} BlinkToRadioMsg;

#endif 
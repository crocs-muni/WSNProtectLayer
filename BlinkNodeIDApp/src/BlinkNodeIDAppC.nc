// $Id: BlinkToRadioAppC.nc,v 1.4 2006/12/12 18:22:52 vlahan Exp $
#define NEW_PRINTF_SEMANTICS

#include <Timer.h>
#include "printf.h"

/**
 * App for visual verification of the programmed node ID.
 * 
 * After boot "delimitier" is signalled by LEDS:
 * Numbers 1,2,4 are signalled consequently, separated by 250 ms time slot.
 * This is information for user that node has booted and 
 * how LEDS are numbered (bits -> LEDS correspondence).
 * 
 * After this delimitier, the following process takes place:
 * 1. 3 least significant bits of the node id are signalled,
 * 2. 2000 ms sleep,
 * 3. next 3 bits (mask 0b111000) are signalled,
 * 4. 2000 ms sleep,
 * 5. goto: begin (delimitier)
 * 
 */
configuration BlinkNodeIDAppC {
}
implementation {
  components MainC;
  components LedsC;
  components BlinkNodeIDC as App;
  components new TimerMilliC() as Timer0;

  components PrintfC;
  components SerialStartC;
  
  // init timer (radio init)
  components new TimerMilliC() as InitTimer;
  
  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.InitTimer -> InitTimer;
} 

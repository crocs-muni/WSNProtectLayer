

#include <Timer.h>
#include "printf.h"

module BlinkNodeIDC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Timer<TMilli> as InitTimer;
}
implementation {
  enum {
	TIMER_START=2000,
	TIMER_STEP=2000,
	TIMER_DELIM=250,
	MAX_STEPS=2,				// Max node ID = 2^(3*MAX_STEPS)
	LEDS_MASK=0x7, 
	LEDS_CNT=3
  };
  
  uint16_t initState=0;	// Initialization state of the node; 0->1->2
  uint16_t subState=0;

  void setLeds(uint16_t val) {
    if (val & 0x01)
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (val & 0x02)
      call Leds.led1On();
    else
      call Leds.led1Off();
    if (val & 0x04)
      call Leds.led2On();
    else
      call Leds.led2Off();
  }

  event void Boot.booted() {
	call InitTimer.startOneShot(TIMER_START);
  }
  
  event void InitTimer.fired() {
      if (initState>=MAX_STEPS){
      	 initState=0;
      	 subState=0;
      	 setLeds(0);
      	 
      	 call InitTimer.startOneShot(TIMER_START);
      } else {
      	if (subState>=4){
	      	uint16_t curBlink = (TOS_NODE_ID >> (initState*LEDS_CNT)) & LEDS_MASK;
	      	setLeds(curBlink);
	      	
	      	printf("CurBlink [%u] value[%u] nodeId: [%u]\n", initState, curBlink, TOS_NODE_ID);
	      	printfflush();
	      	
	      	initState += 1;
	      	call InitTimer.startOneShot(TIMER_STEP);
	      	
      	} else {
      		setLeds(subState <=3 ? (1<<subState) : 0);
      		subState+=1;
      		
      		call InitTimer.startOneShot(TIMER_DELIM);
      	}
      }
  }
  
  event void Timer0.fired() {
    dbg("NodeState", "Timer fired.\n");  
    printf("## Timer fired.\n");
	printfflush();
	
    
  }
} 
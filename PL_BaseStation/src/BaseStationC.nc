// $Id: BlinkToRadioC.nc,v 1.5 2007/09/13 23:10:23 scipio Exp $

/*
 * "Copyright (c) 2000-2006 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 */

/**
 * Base station application.
 * Starts privacy layer component (radio & basic components gets started).
 * Then AMControl.startDone() is signalized. Route (CTP) component is not started.
 * 
 * Then this app should generate magic packet to wake up nodes in the network. Magic
 * packet is just first change of the privacy level. This packet should be re-trasmitted 
 * multiple times to be sure the whole network received it. 
 * 
 * Then this app should call Dispatcher.serveState() in order to finish initialization
 * of the components of the PL. Namely RouteC and CTP. CTP is started on nodes upon
 * receipt of the magic packet. 
 *
 * @author Prabal Dutta
 * @date   Feb 1, 2006
 */
#include <Timer.h>
#include "BaseStation.h"
#include <UserButton.h>

module BaseStationC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as InitTimer;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;

  uses interface SplitControl as AMControl;
  
  uses interface Get<button_state_t>;
  uses interface Notify<button_state_t>;
  
  uses interface Dispatcher;
}
implementation {
  enum {
  		TIMER_START=5000,
  		TIMER_FAIL_START=1000,
  };
  
  // Initialization state of the node;
  // 0 = after reboot -> start radio
  // 1= radio started successfully -> start program
  int initState=0;	
  
  // Current privacy level, is initialized to -1 at the beginning
  // since the network waits for the "magic packet" after deployment.
  int8_t curPrivLvl = -1;
  
  uint16_t counter;
  message_t pkt;
  bool busy = FALSE;
  uint32_t received_packets = 0;

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
    call Leds.led0On();
    call Notify.enable();

    // Prepare initialization TIMER_START ms after boot.
    // Due to this delay one is able to attach PrintfClient
    // after node reset so no message is missed.
	call InitTimer.startOneShot(TIMER_START);
  }
  
  void task startRadio() {      
      call AMControl.start();
      call Leds.led1Toggle();
  }
  
  event void InitTimer.fired() {
      call Leds.led1Toggle();
      
      if (initState==0){
      	// State 0 -> start radio (& underlying PL).
      	post startRadio();
      } else {
      	call Timer0.startOneShot(TIMER_PERIOD_MILLI);
	    dbg("NodeState", "Radio started successfully.\n");
	    
	    call Leds.led2On();
      }
  }
  
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      initState=1;
    }
    
    call InitTimer.startOneShot(TIMER_FAIL_START);
  }
	
  event void AMControl.stopDone(error_t err) {
  }
	
  event void Timer0.fired() {
    dbg("NodeState", "Timer fired.\n");  
    printf("## Timer fired. busy=%d counter=%d\n", busy, counter);
    
    call Leds.led2Toggle();
    printfflush();
	
    counter++;
    if (!busy) {
      BlinkToRadioMsg* btrpkt = 
	(BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
      if (btrpkt == NULL) {
      	printf("## ERROR\n"); 
		return;
      }
      
      atomic{
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      }
      
     /* if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
      	call Leds.led1Toggle();
        busy = TRUE;
      }*/
    }
    
    //if (busy == FALSE){
    	call Timer0.startOneShot(TIMER_PERIOD_MILLI);
    //}    
  }

  
  
  event void Notify.notify(button_state_t state) {
		if ( state == BUTTON_PRESSED ) {
			
		}
  }
  
  event void Dispatcher.stateChanged(uint8_t newState){ 
  	
  }
	
} 
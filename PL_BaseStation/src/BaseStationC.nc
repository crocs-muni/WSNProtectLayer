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
 * Forwarding code taken form BaseStation.
 * 
 * @author Ph4r05
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
  
  uses interface AMSend as PrivChangeSend;
  
  // FWDing
  uses interface AMSend as UartSend[am_id_t id];
  uses interface Receive as UartReceive[am_id_t id];
  uses interface Packet as UartPacket;
  uses interface AMPacket as UartAMPacket;
    
  uses interface AMSend as RadioSend[am_id_t id];
  uses interface Receive as RadioReceive[am_id_t id];
  uses interface Receive as RadioSnoop[am_id_t id];
  uses interface Packet as RadioPacket;
  uses interface AMPacket as RadioAMPacket;
}
implementation {
  enum {
  		TIMER_START=5000,
  		TIMER_FAIL_START=1000,
  };
  
  // Logging tag for this component
  static const char *TAG = "BS";
  
  // Initialization state of the node;
  // 0 = after reboot -> start radio
  // 1= radio started successfully -> start program
  int initState=0;	
  
  // Current privacy level, is initialized to -1 at the beginning
  // since the network waits for the "magic packet" after deployment.
  int8_t curPrivLvl = -1;
  // Counter for privacy level change signatures.
  int8_t plvlCounter = -1;
  
  // Represents current blick status. 
  int16_t blinkState = 0;
  
  // Sending state for privacy level change.
  uint8_t sendState = 0; 
  
  // Number of sent privacy level change messages in one state.
  uint8_t plevelMsgs = 0;
  
  message_t pkt;
  bool busy = FALSE;
  
  message_t  uartQueueBufs[UART_QUEUE_LEN];
  message_t  * ONE_NOK uartQueue[UART_QUEUE_LEN];
  uint8_t    uartIn, uartOut;
  bool       uartBusy, uartFull;

  message_t  radioQueueBufs[RADIO_QUEUE_LEN];
  message_t  * ONE_NOK radioQueue[RADIO_QUEUE_LEN];
  uint8_t    radioIn, radioOut;
  bool       radioBusy, radioFull;
  
  task void uartSendTask();
  task void radioSendTask();

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
    uint8_t i;
    for (i = 0; i < UART_QUEUE_LEN; i++){
      uartQueue[i] = &uartQueueBufs[i];
    }
    
    uartIn = uartOut = 0;
    uartBusy = FALSE;
    uartFull = FALSE;

    for (i = 0; i < RADIO_QUEUE_LEN; i++){
      radioQueue[i] = &radioQueueBufs[i];
    }
    
    radioIn = radioOut = 0;
    radioBusy = FALSE;
    radioFull = FALSE;
	call Leds.led0On();
	
    // Prepare initialization TIMER_START ms after boot.
    // Due to this delay one is able to attach PrintfClient
    // after node reset so no message is missed.
    call Notify.enable();
	call InitTimer.startOneShot(TIMER_START);
  }
  
  void task startRadio() {    
	  BS_PRINTF(pl_log_d(TAG, "<radioStart>\n"));
      call AMControl.start();
      call Leds.led1Toggle();
  }
  
  event void InitTimer.fired() {
      call Leds.led1Toggle();
      
      if (initState==0){
      	// State 0  -> start radio (& underlying PL).
      	post startRadio();
      } else {
      	// State 1+ -> node is prepared.
	    call Leds.led2On();
		BS_PRINTF(pl_log_d(TAG, "</radioStart>\n"));
      }
  }
  
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      initState=1;
    }
    
    call InitTimer.startOneShot(TIMER_FAIL_START);
  }
	
  /**
   * Sends current privacy level packet
   */
  task void sendPlevel(){
  		if(!busy) {
			PLevelMsg_t * plvlMsg = (PLevelMsg_t * ) call Packet.getPayload(&pkt, sizeof(PLevelMsg_t));

			if(plvlMsg == NULL) {
				BS_PRINTF(pl_log_e(TAG, "null msg\n"));
				BS_PRINTFFLUSH();
				
				return;
			}
			
			plvlMsg->newPLevel = curPrivLvl;
			plvlMsg->counter = plvlCounter;
			
			// TODO signature
			plvlMsg->signature[0] = 0;
			
			if(call PrivChangeSend.send(AM_BROADCAST_ADDR, &pkt, (uint8_t) sizeof(PLevelMsg_t)) == SUCCESS) {
				busy = TRUE;
				BS_PRINTF(pl_log_d(TAG, "send()==SUCCESS\n"));
			} else {
				post sendPlevel();
				BS_PRINTF(pl_log_w(TAG, "send()!=SUCCESS\n"));
			}
		} else {
			BS_PRINTF(pl_log_w(TAG, "send() busy\n"));
			post sendPlevel();
		}
		
		BS_PRINTFFLUSH();
  }
	
  event void AMControl.stopDone(error_t err) { }
  event void Timer0.fired() {
	BS_PRINTF(pl_log_d(TAG, "fired, sendState=%u, blink=%u lvl=%d ctr=%d\n", sendState, blinkState, curPrivLvl, plvlCounter));
  	if (sendState==0){
  		// Blicking state.
  		if (blinkState >= 2*TIMER_BLINK_COUNT){
			// Transition to sending state
			sendState = 1; 
			setLeds(curPrivLvl+1);
			call Timer0.startOneShot(TIMER_BLINK_PAUSE_SHORT);
			return;
  		}
  		
  		if ((blinkState % 2) == 0){
  			setLeds(curPrivLvl+1);
  			call Timer0.startOneShot(TIMER_BLINK_PAUSE);
  			
  		} else {
  			setLeds(0);	
  			call Timer0.startOneShot(TIMER_BLINK_PAUSE_SHORT);
  		}
  		blinkState += 1;
  	} else if (sendState==1){
  		// Sending state.
  		
  		// Increment counter if triggered
  		if (blinkState >= 2*TIMER_BLINK_COUNT){
  			BS_PRINTF(pl_log_d(TAG, "counterInc()\n"));
  			
  			plvlCounter += 1;
  			blinkState = 0;
  		}
  		
  		post sendPlevel();
  	} else if (sendState==2){
  		// Privacy level state changed.
  		// If it was magic packet, init routing.
  		setLeds(curPrivLvl+1);
  		if (plvlCounter==0){
  			BS_PRINTF(pl_log_d(TAG, "serveState(), magicPacket\n"));
  			call Dispatcher.serveState();
  			
  		} else {
  			blinkState=0;
  			sendState=3;
  			call Timer0.startOneShot(TIMER_BLINK_PAUSE_SHORT);
  			
  		}
  		
  		BS_PRINTFFLUSH();
  	} else if (sendState==3){
  		// finished signalization
  		if (blinkState >= 4){
  			sendState=4;
			setLeds(curPrivLvl+1);
  		}
  		
  		if ((blinkState % 2) == 0){
  			setLeds(curPrivLvl+1);
  			call Timer0.startOneShot(TIMER_BLINK_PAUSE);
  			
  		} else {
  			setLeds(0);	
  			call Timer0.startOneShot(TIMER_BLINK_PAUSE);
  		}
  		blinkState += 1;
  		BS_PRINTFFLUSH();
  	}
  }
  
  event void Notify.notify(button_state_t state) {
  		// React on button released event. 
		if (state == BUTTON_RELEASED && sendState!=3 && sendState!=4){		// BUTTON_PRESSED
			BS_PRINTF(pl_log_d(TAG, "buttonReleased\n"));
			BS_PRINTFFLUSH();
			
			// If radio is not started yet, we have to wait for it.
			if (initState==0) return;
			
			// Increment privacy level modulo NUM.
			curPrivLvl = (curPrivLvl + 1) % PLEVEL_NUM;
			
			// Start timer with blicking.
			blinkState = 0;
			sendState  = 0;
			plevelMsgs = 0;
			call Timer0.startOneShot(TIMER_BLINK_PAUSE_SHORT);
		}
  }
  
  event void Dispatcher.stateChanged(uint8_t newState){ 
  	if (newState==STATE_WORKING){
  		sendState=3;
  		blinkState=0;
  		
  		BS_PRINTF(pl_log_d(TAG, "Dispatcher.stateChanged %u\n", newState));
  		BS_PRINTFFLUSH();
  		
  		call Timer0.startOneShot(TIMER_BLINK_PAUSE_SHORT);
  	}
  }
  
  event void PrivChangeSend.sendDone(message_t * msg, error_t error){
  		if (msg==&pkt){
			busy = FALSE;
			BS_PRINTF(pl_log_d(TAG, "sendDone[%u], msgCnt=%u\n", error, plevelMsgs));
			
			if(error == SUCCESS) {
				call Leds.led2Toggle();
				
				plevelMsgs += 1;
				if (plevelMsgs >= PLEVEL_MSGS){
					// We have enough messages sent, not sneding anymore.
					sendState = 2;
				}
				
				call Timer0.startOneShot(PLEVEL_WAIT);
			}
			else {
				call Timer0.startOneShot(250);
			}
		}
  }
  
  //
  // FWDing state
  //
  uint8_t count = 0;
  uint8_t tmpLen;
  
  message_t* ONE receive(message_t* ONE msg, void* payload, uint8_t len);
  event message_t *RadioSnoop.receive[am_id_t id](message_t *msg, void *payload, uint8_t len) {
    return receive(msg, payload, len);
  }
  event message_t *RadioReceive.receive[am_id_t id](message_t *msg, void *payload, uint8_t len) {
    return receive(msg, payload, len);
  }
  
  message_t* receive(message_t *msg, void *payload, uint8_t len) {
    message_t *ret = msg;
    atomic {
      if (!uartFull){
		ret = uartQueue[uartIn];
		uartQueue[uartIn] = msg;
		
		uartIn = (uartIn + 1) % UART_QUEUE_LEN;
		
		if (uartIn == uartOut)
		  uartFull = TRUE;
		
		if (!uartBusy){
		  post uartSendTask();
		  uartBusy = TRUE;
		}
	  }
    }
    return ret;
  }

  
  task void uartSendTask() {
    uint8_t len;
    am_id_t id;
    am_addr_t addr, src;
    message_t* msg;
    am_group_t grp;
    atomic if (uartIn == uartOut && !uartFull) {
	  uartBusy = FALSE;
	  return;
	}

    msg = uartQueue[uartOut];
    tmpLen = len = call RadioPacket.payloadLength(msg);
    id = call RadioAMPacket.type(msg);
    addr = call RadioAMPacket.destination(msg);
    src = call RadioAMPacket.source(msg);
    grp = call RadioAMPacket.group(msg);
    call UartPacket.clear(msg);
    call UartAMPacket.setSource(msg, src);
    call UartAMPacket.setGroup(msg, grp);

    if (call UartSend.send[id](addr, uartQueue[uartOut], len) == SUCCESS){
      //call Leds.led1Toggle();
    } else {
		//failBlink();
		post uartSendTask();
    }
  }

  event void UartSend.sendDone[am_id_t id](message_t* msg, error_t error) {
    if (error != SUCCESS){
      //failBlink();
    } else {
      atomic if (msg == uartQueue[uartOut]){
	    if (++uartOut >= UART_QUEUE_LEN)
	      uartOut = 0;
	    if (uartFull)
	      uartFull = FALSE;
	  }
	}
    post uartSendTask();
  }

  event message_t *UartReceive.receive[am_id_t id](message_t *msg, void *payload, uint8_t len) {
    message_t *ret = msg;
    bool reflectToken = FALSE;

    atomic if (!radioFull) {
	  reflectToken = TRUE;
	  ret = radioQueue[radioIn];
	  radioQueue[radioIn] = msg;
	  if (++radioIn >= RADIO_QUEUE_LEN)
	    radioIn = 0;
	  if (radioIn == radioOut)
	    radioFull = TRUE;

	  if (!radioBusy)
	    {
	      post radioSendTask();
	      radioBusy = TRUE;
	    }
	} else {
		//dropBlink();
	}

    if (reflectToken) {
      //call UartTokenReceive.ReflectToken(Token);
    }
    
    return ret;
  }

  task void radioSendTask() {
    uint8_t len;
    am_id_t id;
    am_addr_t addr,source;
    message_t* msg;
    
    atomic if (radioIn == radioOut && !radioFull) {
	  radioBusy = FALSE;
	  return;
	}

    msg = radioQueue[radioOut];
    len = call UartPacket.payloadLength(msg);
    addr = call UartAMPacket.destination(msg);
    source = call UartAMPacket.source(msg);
    id = call UartAMPacket.type(msg);

    call RadioPacket.clear(msg);
    call RadioAMPacket.setSource(msg, source);
    
    if (call RadioSend.send[id](addr, msg, len) == SUCCESS){
      //call Leds.led0Toggle();
    } else {
		//failBlink();
		post radioSendTask();
    }
  }

  event void RadioSend.sendDone[am_id_t id](message_t* msg, error_t error) {
    if (error != SUCCESS){
      //failBlink();
    } else {
      atomic if (msg == radioQueue[radioOut]){
	    if (++radioOut >= RADIO_QUEUE_LEN)
	      radioOut = 0;
	    if (radioFull)
	      radioFull = FALSE;
	  }
	}
    
    post radioSendTask();
  }
  
} 
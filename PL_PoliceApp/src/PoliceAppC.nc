// $Id:PoliceAppC.nc,v 1.5 2007/09/13 23:10:23 scipio Exp $


/*
 * "Copyright (c) 2012-2013 XXX
 * All rights reserved.
 *
 
Based on BlinkToRadio example


 *
 * @author Petr Svenda
 * @date   Jan 1, 2013
 */

#include <Timer.h>
#include "PoliceApp.h"
#include "../../ProtectLayer/src/ProtectLayerGlobals.h"
#include "printf.h"

module PoliceAppC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as TimerStillAlive;
  uses interface Timer<TMilli> as TimerMSNDetect;
  uses interface Timer<TMilli> as InitTimer;
  uses interface Packet;
  //uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface MovementSensor;
  uses interface CC2420Packet;
}
implementation {

  uint16_t counter = 0;
  message_t pkt;
  bool busy = FALSE;
  uint32_t received_packets = 0;
  
  // Initialization state of the node;
  // 0 = after reboot -> start radio
  // 1= radio started successfully -> start program
  int initState=0;	

  void setLeds(uint16_t val) {
      printf("NodeState, setLeds%u\n", val);

      if (val & 0x01) call Leds.led0Toggle();
      if (val & 0x02) call Leds.led1Toggle();
      if (val & 0x04) call Leds.led2Toggle();
/*
      if (val & 0x01) call Leds.led0On();
      else call Leds.led0Off();
      if (val & 0x02) call Leds.led1On();
      else call Leds.led1Off();
      if (val & 0x04) call Leds.led2On();
      else call Leds.led2Off();
*/
  }

  event void Boot.booted() {
    call Leds.led0On();

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
      	post startRadio();
      	
      } else {
      	
      	// Radio was initialized properly.
      	call TimerStillAlive.startPeriodic(TIMER_STILL_ALIVE);
      	
      	// not used now call TimerMSNDetect.startPeriodic(TIMER_MSN_DETECTED);
      	printf("NodeState, Radio started successfully.\n");
      	
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
  
  task void stillAlive(){
  	counter++;
    printf("TimerStillAlive fired with counter %u.\n", counter);

    if (!busy) {
      PoliceAppMsg_StillAlive* btrpkt = (PoliceAppMsg_StillAlive*)(call Packet.getPayload(&pkt, sizeof(PoliceAppMsg_StillAlive)));
      if (btrpkt == NULL) {
        return;
      }
      //call CC2420Packet.setPower(&pkt, 3);

      btrpkt->messageType = MSGTYPE_STILLALIVE;
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PoliceAppMsg_StillAlive)) == SUCCESS) {
        busy = TRUE;
      }
    } else post stillAlive();
  }

  event void TimerStillAlive.fired() {
    setLeds(2);
	post stillAlive();
  }

  task void MSNDetected(){
  	
    printf("NodeState, TimerMSNDetect fired.\n");

    counter++;
    if (!busy) {
      PoliceAppMsg_MSNDetected* btrpkt = (PoliceAppMsg_MSNDetected*)(call Packet.getPayload(&pkt, sizeof(PoliceAppMsg_MSNDetected)));
      if (btrpkt == NULL) return;

      call CC2420Packet.setPower(&pkt, 3);

      btrpkt->messageType = MSGTYPE_MSNDETECTED;
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      if (call AMSend.send(AM_BROADCAST_ADDR, 
          &pkt, sizeof(PoliceAppMsg_MSNDetected)) == SUCCESS) {
        busy = TRUE;
      }
    } else post MSNDetected();
  }

  event void TimerMSNDetect.fired() {
    setLeds(4);
    post MSNDetected();
  }

  task void movementDetected(){
  	printf("NodeState, movementDetected.\n");
    //setLeds(1);
	call Leds.led0Toggle();
    counter++;
    if (!busy) {
      PoliceAppMsg_MovementDetected* btrpkt = (PoliceAppMsg_MovementDetected*)(call Packet.getPayload(&pkt, sizeof(PoliceAppMsg_MovementDetected)));
      if (btrpkt == NULL) return;

      //call CC2420Packet.setPower(&pkt, 3);

      btrpkt->messageType = MSGTYPE_MOVEMENTDETECTED;
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PoliceAppMsg_MovementDetected)) == SUCCESS) {
           busy = TRUE;
      }
    } else post movementDetected();
  }

  event void MovementSensor.movementDetected() {
    post movementDetected();
  }
  
  task void movementMSNDetected(){
  	printf("NodeState, movementMSNDetected.\n");
    call Leds.led1Toggle();
//    setLeds(2);

    counter++;
    if (!busy) {
      PoliceAppMsg_MovementDetected* btrpkt = (PoliceAppMsg_MovementDetected*)(call Packet.getPayload(&pkt, sizeof(PoliceAppMsg_MovementDetected)));
      if (btrpkt == NULL) return;

      //call CC2420Packet.setPower(&pkt, 3);

      btrpkt->messageType = MSGTYPE_MSNDETECTED;
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PoliceAppMsg_MovementDetected)) == SUCCESS) {
           busy = TRUE;
      }
    } else post movementMSNDetected();
  }
  
  event void MovementSensor.movementMSNDetected() {
    post movementMSNDetected();
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    printf("PoliceAppC, Message received.\n");
/*
    // Distinguish between different message types 	
    if ((*(nx_uint16_t*) payload) == MSGTYPE_STILLALIVE) {
      PoliceAppMsg_StillAlive* btrpkt = (PoliceAppMsg_StillAlive*)payload;
      setLeds(btrpkt->counter);
      received_packets++;
      dbg("NodeState", "Sender is: %d, values is: %d.\n", btrpkt->nodeid, btrpkt->counter);
    }
//TODO: react on others if needed
*/
    return msg;
  }
} 

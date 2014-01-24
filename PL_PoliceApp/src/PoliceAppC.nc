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

  void setLeds(uint16_t val) {
      PrintDbg("NodeState", "setLeds%u\n", val);

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
    PrintDbg("NodeState", "Node has booted.\n");
	call AMControl.start();
    
    //dbg("NodeState", "Node has booted.\n");

  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call TimerStillAlive.startPeriodic(TIMER_STILL_ALIVE);
      // not used now call TimerMSNDetect.startPeriodic(TIMER_MSN_DETECTED);
      PrintDbg("NodeState", "Radio started successfully.\n");

    }
    else {
      call AMControl.start();
      PrintDbg("NodeState", "Radio did not start!\n");

    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void TimerStillAlive.fired() {
    setLeds(2);

    counter++;
    //PrintDbg("NodeState", "TimerStillAlive fired with counter %x %x.\n", counter & 0xff, (counter >> 8) & 0xff);
    PrintDbg("NodeState", "TimerStillAlive fired with counter.\n");

    if (!busy) {
      PoliceAppMsg_StillAlive* btrpkt = (PoliceAppMsg_StillAlive*)(call Packet.getPayload(&pkt, sizeof(PoliceAppMsg_StillAlive)));
      if (btrpkt == NULL) {
        return;
      }
      call CC2420Packet.setPower(&pkt, 3);

      btrpkt->messageType = MSGTYPE_STILLALIVE;
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PoliceAppMsg_StillAlive)) == SUCCESS) {
        busy = TRUE;
      }

    }
  }

  event void TimerMSNDetect.fired() {
    setLeds(4);
    PrintDbg("NodeState", "TimerMSNDetect fired.\n");

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

    }
  }

  event void MovementSensor.movementDetected() {
    PrintDbg("NodeState", "movementDetected.\n");
    setLeds(1);

    counter++;
    if (!busy) {
      PoliceAppMsg_MovementDetected* btrpkt = (PoliceAppMsg_MovementDetected*)(call Packet.getPayload(&pkt, sizeof(PoliceAppMsg_MovementDetected)));
      if (btrpkt == NULL) return;

      call CC2420Packet.setPower(&pkt, 3);

      btrpkt->messageType = MSGTYPE_MOVEMENTDETECTED;
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PoliceAppMsg_MovementDetected)) == SUCCESS) {
           busy = TRUE;
      }

    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    PrintDbg("PoliceAppC", "Message received.\n");
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

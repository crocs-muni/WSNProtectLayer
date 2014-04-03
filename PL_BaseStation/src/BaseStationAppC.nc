// $Id: BlinkToRadioAppC.nc,v 1.4 2006/12/12 18:22:52 vlahan Exp $

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

#include "BaseStation.h"


#include <Timer.h>
#define NEW_PRINTF_SEMANTICS

configuration BaseStationAppC {
}
implementation {
  components MainC;
  components LedsC;
  components BaseStationC as App;
  components new TimerMilliC() as BlinkAndSendTimer;
  components new TimerMilliC() as InitTimer; // init timer (radio init)
  components UserButtonC;
  
  components ProtectLayerC;
  
  components PrintfC;
  components SerialStartC;
  
  components DispatcherC;
  components SharedDataC;
  components CryptoP;
  components new AMSenderC(AM_CHANGEPL);
  
  // FWDing
  components ActiveMessageC as Radio;
  components SerialActiveMessageC as Serial;
  
  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.BlinkAndSendTimer -> BlinkAndSendTimer;
  App.InitTimer -> InitTimer;
  App.AMControl -> ProtectLayerC.AMControl;
  
  App.Get -> UserButtonC;
  App.Notify -> UserButtonC;
  
  App.Dispatcher -> DispatcherC;
  App.SharedData -> SharedDataC;
  App.Crypto -> CryptoP;
  
  App.PrivChangeSend -> AMSenderC;
  App.Packet -> AMSenderC;
  
  // FWDing
  //App.RadioControl -> Radio;
  //App.SerialControl -> Serial;
  
  App.UartSend -> Serial;
  App.UartReceive -> Serial.Receive;
  App.UartPacket -> Serial;
  App.UartAMPacket -> Serial;
  
  App.RadioSend -> Radio;
  App.RadioReceive -> Radio.Receive;
  App.RadioSnoop -> Radio.Snoop;
  App.RadioPacket -> Radio;
  App.RadioAMPacket -> Radio;	
} 

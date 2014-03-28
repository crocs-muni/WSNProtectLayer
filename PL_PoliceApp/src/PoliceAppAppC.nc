// $Id: PoliceAppAppC.nc,v 1.4 2006/12/12 18:22:52 vlahan Exp $

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

configuration PoliceAppAppC {
}
implementation {
  components MainC;
  components LedsC;
  components PoliceAppC as App;
  components new TimerMilliC() as TimerStillAlive;
  components new TimerMilliC() as TimerMSNDetect;
  components new TimerMilliC() as InitTimer; // init timer (radio init)
  //components ePIRC;
  components IntruderDetectC;
  components CC2420ActiveMessageC;

  components PrintfC;
  components SerialStartC;
  
  //App.Boot -> MainC;

  components ProtectLayerC;


  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.TimerStillAlive -> TimerStillAlive;
  App.TimerMSNDetect -> TimerMSNDetect;
  App.InitTimer -> InitTimer;

  App.Packet -> ProtectLayerC.Packet; 
  //App.AMPacket -> PrivacyC; // not used at all
  App.AMControl -> ProtectLayerC.AMControl;
  App.AMSend -> ProtectLayerC.AMSend;
  App.Receive -> ProtectLayerC.Receive;
  //App.MovementSensor -> ePIRC;
  App.MovementSensor -> IntruderDetectC;
  App.CC2420Packet -> CC2420ActiveMessageC;

} 

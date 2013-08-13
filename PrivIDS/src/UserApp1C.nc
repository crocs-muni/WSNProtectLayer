#include "ProtectLayerGlobals.h"
configuration UserApp1C {
	provides {
		interface Init;
	}
}
implementation {
	components MainC;
	components PrivIDSC, ePIRC, UserApp1P;   
	components new TimerMilliC() as Timer0; 
	components ePIRC as ePIR1; 
	//components new ePIRC() as ePIR2; 
  
	//MainC.SoftwareInit -> UserApp1P.Init;	// auto-initialization
	Init = UserApp1P.Init;					// possibility for re-init
	
    UserApp1P.MovementSensor1 -> ePIR1.MovementSensor; 
    //UserApp1P.MovementSensor2 -> ePIR2.MovementSensor; 
	
	UserApp1P.AppMessagesSend -> PrivIDSC.AMSend;		// use protect layer
	UserApp1P.AppMessagesReceive -> PrivIDSC.Receive;	// use protect layer
	
	UserApp1P.Timer0 -> Timer0; 
}

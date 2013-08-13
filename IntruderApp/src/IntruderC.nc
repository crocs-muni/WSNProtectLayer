#include "../../ProtectLayer/src/ProtectLayerGlobals.h"

configuration IntruderC {
	provides {		
		interface Init;
	}
}
implementation {
	components MainC;
	components IntruderP;
	components new TimerMilliC();
	components new AMSenderC(AM_INTRUSION_MSG);
	components ActiveMessageC;
	components LedsC;
	
	MainC.SoftwareInit -> IntruderP.Init;	//auto-initialization
	
	Init = IntruderP.Init;

	IntruderP.RadioControl -> ActiveMessageC;
	
	IntruderP.Timer -> TimerMilliC;
	
	IntruderP.AMSend -> AMSenderC;
	IntruderP.AMPacket -> AMSenderC;
	IntruderP.Packet -> AMSenderC;
	IntruderP.Acks -> AMSenderC;
	
	IntruderP.Leds -> LedsC;
}

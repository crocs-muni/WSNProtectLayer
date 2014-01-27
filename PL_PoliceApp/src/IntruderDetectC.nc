#include "ProtectLayerGlobals.h"

configuration IntruderDetectC {
	provides {
		interface MovementSensor;
	}
}
implementation {
	components MainC;
	components IntruderDetectP;
	components new AMReceiverC(AM_INTRUSION_MSG);
	components CC2420ActiveMessageC; 
	components LedsC;
	
	MovementSensor = IntruderDetectP.MovementSensor;
	
	IntruderDetectP.Receive -> AMReceiverC;
	IntruderDetectP.CC2420Packet -> CC2420ActiveMessageC;
	
	IntruderDetectP.Leds -> LedsC;
}

#include "ProtectLayerGlobals.h"
configuration IDSForwarderC {
}
implementation {
	components IDSForwarderP;
	components DispatcherC;
	components MainC;
	components new AMSenderC(AM_IDS_ALERT);
	 
	IDSForwarderP.Receive -> DispatcherC.IDS_Receive;

	MainC.SoftwareInit -> IDSForwarderP.Init; // auto init phase 1
		
    IDSForwarderP.AMSend -> AMSenderC;
}
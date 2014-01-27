#include "ProtectLayerGlobals.h"
configuration ForwarderC {
}
implementation {
    components PrivacyC;
    components ForwarderP;
    components MainC;

   
	
	MainC.SoftwareInit -> ForwarderP.Init; // auto init phase 1
		
    ForwarderP.AMSend -> PrivacyC.MessageSend[MSG_FORWARD];
    ForwarderP.Receive -> PrivacyC.MessageReceive[MSG_FORWARD];
}

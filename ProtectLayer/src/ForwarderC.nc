#include "ProtectLayerGlobals.h"
configuration ForwarderC {
}
implementation {
    components MainC;
    components ForwarderP;
    
#ifndef THIS_IS_BS
	components PrivacyC;
#endif
	
	MainC.SoftwareInit -> ForwarderP.Init; // auto init phase 1
#ifndef THIS_IS_BS
    ForwarderP.AMSend -> PrivacyC.MessageSend[MSG_FORWARD];
    ForwarderP.Receive -> PrivacyC.MessageReceive[MSG_FORWARD];
#endif
}

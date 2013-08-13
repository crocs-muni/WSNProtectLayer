#include "ProtectLayerGlobals.h"
configuration ForwarderC {
    provides {
		interface Init;
                }
}
implementation {
    components PrivacyC;
    components ForwarderP;

    Init = ForwarderP.Init;
	
	
		
    ForwarderP.AMSend -> PrivacyC.MessageSend[MSG_FORWARD];
    ForwarderP.Receive -> PrivacyC.MessageReceive[MSG_FORWARD];
}

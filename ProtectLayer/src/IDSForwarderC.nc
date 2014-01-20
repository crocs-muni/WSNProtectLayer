#include "ProtectLayerGlobals.h"
configuration IDSForwarderC {
	provides {
		interface Send as IDSAlertSend;
	}
}
implementation {
	components IDSForwarderP;
	components DispatcherC;
	components MainC;
	components new AMSenderC(AM_IDS_ALERT);
	components new PoolC(message_t, IDS_FORWARDER_SEND_BUFFER_LEN);
	components new QueueC(message_t*, IDS_FORWARDER_SEND_BUFFER_LEN); 
	 
	MainC.SoftwareInit -> IDSForwarderP.Init; // auto init phase 1
	
	IDSForwarderP.Receive -> DispatcherC.IDS_Receive;
		
    IDSForwarderP.AMSend -> AMSenderC;
    IDSForwarderP.Pool -> PoolC;
    IDSForwarderP.SendQueue -> QueueC;
    IDSForwarderP.IDSAlertSend = IDSAlertSend;
}
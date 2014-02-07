#include "ProtectLayerGlobals.h"
configuration IDSForwarderC {
	provides {
		interface AMSend as IDSAlertSend;
		interface Packet as IDSAlertPacket;
	}
}
implementation {
	components IDSForwarderP;
	components DispatcherC;
	components MainC;
#ifndef THIS_IS_BS
	components new AMSenderC(AM_IDS_ALERT);
	components new PoolC(message_t, IDS_FORWARDER_SEND_BUFFER_LEN);
	components new QueueC(message_t*, IDS_FORWARDER_SEND_BUFFER_LEN); 
	components SharedDataC;
	components RouteC;
#endif

	MainC.SoftwareInit -> IDSForwarderP.Init; // auto init phase 1
	
	IDSAlertSend = IDSForwarderP.IDSAlertSend;
    IDSAlertPacket = IDSForwarderP.IDSAlertPacket;
    
#ifndef THIS_IS_BS	
	IDSForwarderP.Receive -> DispatcherC.IDS_Receive;
		
    IDSForwarderP.AMSend -> AMSenderC;
    IDSForwarderP.Pool -> PoolC;
    IDSForwarderP.SendQueue -> QueueC;
    
    IDSForwarderP.Route -> RouteC.Route;
    IDSForwarderP.Packet -> AMSenderC;
#endif
}
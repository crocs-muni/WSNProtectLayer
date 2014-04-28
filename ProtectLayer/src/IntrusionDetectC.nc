/**
 * Configuration IntrusionDetectC acts as a front-end for the IntrusionDetectP component. 
 * All components using IntrusionDetectP should wire to this configuration not directly to the IntrusionDetectP.
 * The configuration is used to wire the IntrusionDetectP to other components (interface providers).
 * 
 *  @version   1.0
 * 	@date      2012-2014
 **/
 
#include "ProtectLayerGlobals.h"
configuration IntrusionDetectC{
	provides {
		interface IntrusionDetect;
		interface Init as PLInit;
	}
}

implementation{
	components MainC;
	components IntrusionDetectP;
	
#ifndef THIS_IS_BS
	components PrivacyC;
	components SharedDataC;
	
	components CryptoC;
	components DispatcherC;	
	components IDSBufferC;
	components IDSForwarderC;
	components RouteC;
	
	components new AMReceiverC(AM_IDS_ALERT);
#endif
	
	MainC.SoftwareInit -> IntrusionDetectP.Init;	//auto-initialization phase 1
	
	PLInit = IntrusionDetectP.PLInit;
	IntrusionDetect = IntrusionDetectP.IntrusionDetect;

#ifndef THIS_IS_BS	
	IntrusionDetectP.ReceiveIDSMsgCopy -> DispatcherC.Sniff_Receive;
	
	IntrusionDetectP.ReceiveMsgCopy -> PrivacyC.MessageReceive[MSG_IDSCOPY];
	
	IntrusionDetectP.SharedData -> SharedDataC.SharedData;
	
	IntrusionDetectP.Crypto -> CryptoC.Crypto;

	IntrusionDetectP.IDSBuffer -> IDSBufferC.IDSBuffer;

	IntrusionDetectP.AMPacket -> AMReceiverC;
	IntrusionDetectP.Packet -> IDSForwarderC.IDSAlertPacket;
	IntrusionDetectP.AMSend -> IDSForwarderC.IDSAlertSend;
	
	IntrusionDetectP.Route -> RouteC.Route;
#endif
}
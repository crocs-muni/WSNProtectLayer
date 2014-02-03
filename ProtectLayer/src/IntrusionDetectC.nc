/**
 * Configuration IntrusionDetectC acts as a front-end for the IntrusionDetectP component. 
 * All components using IntrusionDetectP should wire to this configuration not directly to the IntrusionDetectP.
 * The configuration is used to wire the IntrusionDetectP to other components (interface providers).
 * 
 **/
 
#ifndef TOSSIM
#include "StorageVolumes.h"
#endif

configuration IntrusionDetectC{
	provides {
		interface IntrusionDetect;
		interface Init as PLInit;
	}
}

implementation{
	components IntrusionDetectP;
	components PrivacyC;
	components SharedDataC;
	components MainC;
//	components new TimerMilliC() as TimerIDS; //testing
//	components new BlockStorageC(VOLUME_LOG) as LogStorage;
	components IDSBufferC;
	components DispatcherC;
	components IDSForwarderC;
	components CryptoC;
	components new AMReceiverC(AM_IDS_ALERT);
//	components new AMSenderC(AM_IDS_ALERT);
		
//	IntrusionDetectP.TimerIDS-> TimerIDS; //testing
	
	MainC.SoftwareInit -> IntrusionDetectP.Init;	//auto-initialization phase 1
	
	PLInit = IntrusionDetectP.PLInit;
	IntrusionDetect = IntrusionDetectP.IntrusionDetect;
	
	IntrusionDetectP.ReceiveIDSMsgCopy -> DispatcherC.Sniff_Receive;
//	IntrusionDetectP.IDSAlertSend -> IDSForwarderC.IDSAlertSend;
	
	IntrusionDetectP.ReceiveMsgCopy -> PrivacyC.MessageReceive[MSG_IDSCOPY];

//	IntrusionDetectP.AMSend -> PrivacyC.MessageSend[MSG_IDS];
//	IntrusionDetectP.Receive -> PrivacyC.MessageReceive[MSG_IDS];
	
	IntrusionDetectP.SharedData -> SharedDataC.SharedData;
	
//	IntrusionDetectP.BlockWrite -> LogStorage.BlockWrite;
	
	IntrusionDetectP.IDSBuffer -> IDSBufferC.IDSBuffer;
	
	IntrusionDetectP.Crypto -> CryptoC.Crypto;
	
	IntrusionDetectP.AMPacket -> AMReceiverC;
	IntrusionDetectP.Packet -> IDSForwarderC.IDSAlertPacket;
	IntrusionDetectP.AMSend -> IDSForwarderC.IDSAlertSend;
}
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
		interface Init;
	}
}
//TODO: IDS component will be decomposed at least into statistics manager, reputation system,
// detection module and connected with add-on when Dusan comes back. 
implementation{
	components IntrusionDetectP;
	components PrivacyC;
	components SharedDataC;
	components MainC;
	components new TimerMilliC() as TimerIDS; //testing
	components new BlockStorageC(VOLUME_LOG) as LogStorage;
	
	IntrusionDetectP.TimerIDS-> TimerIDS; //testing
	
	MainC.SoftwareInit -> IntrusionDetectP.Init;	//auto-initialization
	
	Init = IntrusionDetectP.Init;
	IntrusionDetect = IntrusionDetectP.IntrusionDetect;
	
	IntrusionDetectP.AMSend -> PrivacyC.MessageSend[MSG_IDS];
	IntrusionDetectP.Receive -> PrivacyC.MessageReceive[MSG_IDS];
	
	IntrusionDetectP.ReceiveMsgCopy -> PrivacyC.MessageReceive[MSG_IDSCOPY];
	
	IntrusionDetectP.SharedData -> SharedDataC.SharedData;
	
	IntrusionDetectP.BlockWrite -> LogStorage.BlockWrite;
}
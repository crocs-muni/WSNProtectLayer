/**
 * The basic abstraction of privacy component. It acts as a front-end for the PrivacyP component. 
 * It provides interfaces for privacy management, and for sending and receiving packets with privacy protection. 
 * It provides virtualization of access to AMSenderC and AMReceiverC. It provides parameterized interfces AMSend and Receive. 
 * For every id it provides queue of length one. 
 * All components using PrivacyP should wire to this configuration not directly to the PrivacyP.
 * The configuration is used to wire the PrivacyP to other components (interface providers).
 * 
 * 	@version   0.1
 * 	@date      2012-2013 
 * 
 **/


#include "ProtectLayerGlobals.h"
configuration PrivacyC {
	provides {
		interface Init as PLInit;		
		interface Privacy;
		
		// parameterized interfaces for all different types of messages
		interface AMSend as MessageSend[uint8_t id];	
		interface Receive as MessageReceive[uint8_t id];	
		interface SplitControl as MessageAMControl;
		interface Packet as MessagePacket;
		//interface AMPacket;
	}
}
implementation {
	components MainC;   
	components PrivacyP;   
	components ActiveMessageC;
	components new AMSenderC(AM_PROTECTLAYERRADIO);
	components IntrusionDetectC; 
	components PrivacyLevelC;
	components RouteC;
	components SharedDataC;
	components KeyDistribC;
    components CryptoC;
    components ForwarderC;
    components DispatcherC;
    components new TimerMilliC() as RetxmitTimer;
    components RandomC;


	MainC.SoftwareInit -> PrivacyP.Init; //auto init phase 1
		
	PLInit = PrivacyP.PLInit;
	Privacy = PrivacyP.Privacy;
	
	PrivacyP.PrivacyLevel -> PrivacyLevelC.PrivacyLevel;
	
	MessageSend = PrivacyP.MessageSend;
	MessageReceive = PrivacyP.MessageReceive;
	MessageAMControl = PrivacyP.MessageAMControl;
	MessagePacket = PrivacyP.MessagePacket;
	
	PrivacyP.LowerAMSend -> AMSenderC;
	PrivacyP.LowerReceive -> DispatcherC.PL_Receive;
	PrivacyP.Packet -> AMSenderC;
	PrivacyP.AMPacket -> AMSenderC;
	PrivacyP.AMControl -> ActiveMessageC;
	
	PrivacyP.IntrusionDetect -> IntrusionDetectC.IntrusionDetect;
	//PrivacyP.IntrusionDetectInit -> IntrusionDetectC.Init;
	
	PrivacyP.Route -> RouteC.Route;
	
	PrivacyP.SharedData -> SharedDataC.SharedData;
	PrivacyP.KeyDistrib -> KeyDistribC.KeyDistrib;
	PrivacyP.Crypto -> CryptoC.Crypto;
        
    PrivacyP.Dispatcher -> DispatcherC;
    PrivacyP.RetxmitTimer -> RetxmitTimer;
    PrivacyP.Random -> RandomC;
}

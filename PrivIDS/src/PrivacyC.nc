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
		interface Init;
		
		// parameterized interfaces for all different types of messages	
		interface Receive as MessageReceive[uint8_t id];	

		
		interface AMSend as PrivateSend;
		interface Receive as PrivateReceive;
		interface SplitControl as PrivateAMControl;
		interface Packet as PrivatePacket;
		interface AMSend as ForwardSend;
		interface Experiment;
		
		//interface AMPacket;
	}
}
implementation {
	components MainC;   
	components PrivacyP;   
	components ActiveMessageC;
	components ePIRC;
	components new AMSenderC(AM_PRIVATERADIO);
	components new AMReceiverC(AM_PRIVATERADIO);
	components new PoolC(message_t, SEND_BUFFER_LEN);
	components new QueueC(message_t*, SEND_BUFFER_LEN);
	components new QueueC(uint8_t, COUNT_SEND) as SendOrder;
	components IntrusionDetectC; 
	components RouteC;
	components SharedDataC;
    components CryptoC;
    components ForwarderC;
    components XXTEAC;
    components RoutingTableC;
    components new TimerMilliC() as CheckParentTimer;
    components new TimerMilliC() as SendTimer;
    components new TimerMilliC() as ExperimentTimer;
    components StatsC;
    components LedsC;
	components CC2420PacketC; 
	components RandomMlcgC;

    #ifndef TOSSIM
    components LoggerC;
    #endif
        components PrintfC, SerialStartC;  // support for printf over serial console. Can be removed

	  
	//MainC.SoftwareInit -> PrivacyP.Init;	//auto-initialization
    MainC.SoftwareInit -> ForwarderC.Init;

	PrivacyP.Random        -> RandomMlcgC.Random;
	PrivacyP.RandomInit    -> RandomMlcgC;

	PrivacyP.CC2420Packet ->CC2420PacketC.CC2420Packet; 
	PrivacyP.Leds		  -> LedsC;
    PrivacyP.Pool 	      -> PoolC;
	PrivacyP.SendQueue    -> QueueC;
	PrivacyP.SendOrder	  -> SendOrder;
	
	
	PrivacyP.Stats -> StatsC.Stats;
	Init = PrivacyP.Init;
	
	PrivacyP.ePIRInit -> ePIRC.Init;
	
	Experiment = PrivacyP.Experiment;
	MessageReceive = PrivacyP.MessageReceive;
	
	PrivateSend = PrivacyP.PrivateSend;
	PrivateReceive = PrivacyP.PrivateReceive;
	PrivateAMControl = PrivacyP.PrivateAMControl;
	PrivatePacket = PrivacyP.PrivatePacket;
	ForwardSend = PrivacyP.ForwardSend;


	PrivacyP.SendTimer -> SendTimer;
	PrivacyP.RoutingTable -> RoutingTableC.RoutingTable;
	PrivacyP.XXTEA -> XXTEAC;
	PrivacyP.LowerAMSend -> AMSenderC;
	PrivacyP.LowerReceive -> AMReceiverC;
	PrivacyP.Packet -> AMSenderC;
	PrivacyP.AMPacket -> AMSenderC;
	PrivacyP.AMControl -> ActiveMessageC;
	
	PrivacyP.IntrusionDetect -> IntrusionDetectC.IntrusionDetect;
	PrivacyP.IntrusionDetectInit -> IntrusionDetectC.Init;
	
	PrivacyP.Route -> RouteC.Route;
	
	PrivacyP.SharedData -> SharedDataC.SharedData;
    PrivacyP.Crypto -> CryptoC.Crypto;
    
    PrivacyP.ExperimentTimer -> ExperimentTimer;
    PrivacyP.CheckParentTimer -> CheckParentTimer;
        #ifndef TOSSIM
        PrivacyP.Logger -> LoggerC;
		#endif
}

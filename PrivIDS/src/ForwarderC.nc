#include "ProtectLayerGlobals.h"
configuration ForwarderC {
    provides {
		interface Init;
                }
}
implementation {
    components PrivacyC;
    components ForwarderP;
    components ActiveMessageC;
    components CryptoC;
    components RoutingTableC;
    components new PoolC(message_t, SEND_BUFFER_LEN);
    components new PoolC(SendRequest_t, SEND_BUFFER_LEN) as SendPoolC;
	components new QueueC(SendRequest_t*, SEND_BUFFER_LEN);
	components StatsC;
	components CC2420PacketC; 
	components RandomMlcgC;

    

	ForwarderP.Random        -> RandomMlcgC.Random;
	ForwarderP.RandomInit    -> RandomMlcgC;
	
	
	
    Init = ForwarderP.Init;
	
	ForwarderP.Stats -> StatsC;	
	ForwarderP.RoutingTable -> RoutingTableC.RoutingTable;	
    ForwarderP.AMSend -> PrivacyC.ForwardSend;
    ForwarderP.Receive -> PrivacyC.MessageReceive[MSG_FORWARD];
    ForwarderP.AMPacket ->ActiveMessageC.AMPacket;
	ForwarderP.Crypto -> CryptoC.Crypto;
	ForwarderP.Pool 	      -> PoolC;
	ForwarderP.SendQueue      -> QueueC;
	ForwarderP.SendPool		  -> SendPoolC;
}

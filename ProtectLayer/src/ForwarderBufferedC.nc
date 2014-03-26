#include "ProtectLayerGlobals.h"

/**
 * Buffered message forwarder.
 * Has more slots for messages to forward than default forwarder has (1).
 * In case of error, backoff timer is used to retransmit message. 
 *
 * Taken from CTPForwardingEngineP, main differences:
 *   - No connection to Route - is handled in Privacy component.
 *   - No ACKs since send is done on broadcast (thus no link estimator and sim. stuff).
 *   - NOT TESTED, without compilation errors / warnings.
 */
configuration ForwarderBufferedC {
}
implementation {
    components MainC;
    components ForwarderBufferedP as Forwarder;
    
#ifndef THIS_IS_BS
	components PrivacyC;
	components new PoolC(message_t, FWDER_FORWARD_COUNT) as MessagePoolP;
    components new PoolC(fwd_queue_entry_t, FWDER_FORWARD_COUNT) as QEntryPoolP;
    
	Forwarder.QEntryPool -> QEntryPoolP;
	Forwarder.MessagePool -> MessagePoolP;
	
	components new QueueC(fwd_queue_entry_t*, QUEUE_SIZE) as SendQueueP;
	Forwarder.SendQueue -> SendQueueP;
	
	components new TimerMilliC() as RetxmitTimer;
	Forwarder.RetxmitTimer -> RetxmitTimer;
		
	components RandomC;
	Forwarder.Random -> RandomC;
#endif
	
	MainC.SoftwareInit -> Forwarder.Init; // auto init phase 1
#ifndef THIS_IS_BS
    Forwarder.SubSend -> PrivacyC.MessageSend[MSG_FORWARD];
    Forwarder.Receive -> PrivacyC.MessageReceive[MSG_FORWARD];
#endif
}

/**
 * The basic abstraction of the whole secure platform. It provides interfaces for packet and radio management. 
 * User application should wire to this configuration in order to use security features of the platform. 
 * Packets processed via ProtectLayerC are sent and received via secure platform.
 * 
 * 	@version   0.1
 * 	@date      2012-2013
 * 
 **/


#include "ProtectLayerGlobals.h"
configuration ProtectLayerC{
	provides {
		interface AMSend;	
		interface Receive;	
		//interface AMPacket;	
		interface Packet;
		//interface PacketAcknowledgements
		interface SplitControl as AMControl;
		interface Init;
	}
}
implementation{
	components PrivacyC;
	components IDSForwarderC;


	Init = PrivacyC.Init;	
	AMSend = PrivacyC.MessageSend[MSG_APP];
	Receive = PrivacyC.MessageReceive[MSG_APP];
	AMControl = PrivacyC.MessageAMControl;
	//AMPacket = PrivacyC.AMPacket;
	Packet = PrivacyC.MessagePacket;

}

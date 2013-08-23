/** 
 *  Wiring component for functions related to key distribution providing KeyDistrib interface via KeyDistribP implementation.
 *  This component wires KeyDistribC to implementation from KeyDistribP, connects to Init interface for automatic initialization and wires to cryptographic component.
 * 	@version   0.1
 * 	@date      2012-2013
 */
#include "ProtectLayerGlobals.h"
configuration KeyDistribC {
	provides {
		interface Init;
		interface KeyDistrib;
	}
}
implementation {
	components MainC;   
	components KeyDistribP;  
        components CryptoC;
        components SharedDataC;

   	components new AMSenderC(AM_PROTECTLAYERRADIO);
  	components new AMReceiverC(AM_PROTECTLAYERRADIO);	

	MainC.SoftwareInit -> KeyDistribP.Init;	//auto-initialization

	Init = KeyDistribP.Init;
	KeyDistrib = KeyDistribP.KeyDistrib;
	
	KeyDistribP.Crypto -> CryptoC.Crypto;
        KeyDistribP.SharedData -> SharedDataC.SharedData;

	KeyDistribP.Packet -> AMSenderC;
  	KeyDistribP.AMPacket -> AMSenderC;
  	KeyDistribP.AMSend -> AMSenderC;  	
	KeyDistribP.Receive -> AMReceiverC;

}

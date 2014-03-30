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
	components KeyDistribP;  
	components CryptoC;
	components SharedDataC;
	//components ResourceArbiterC;
        components LedsC;
        
	Init = KeyDistribP.PLInit;
	KeyDistrib = KeyDistribP.KeyDistrib;
	
	KeyDistribP.Crypto -> CryptoC.Crypto;
	KeyDistribP.SharedData -> SharedDataC.SharedData;
	KeyDistribP.ResourceArbiter -> SharedDataC.ResourceArbiter;
	KeyDistribP.Leds -> LedsC;
}

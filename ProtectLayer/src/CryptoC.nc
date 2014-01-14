/** 
 *  Wiring component for cryptographic functions providing Crypto interface via CryptoP implementation.
 *  This component wires CryptoC to implementation from CryptoP and connects to Init interface for automatic initialization.
 *  @version   0.1
 * 	@date      2012-2013
 */
#include "ProtectLayerGlobals.h"
configuration CryptoC {
	provides {
		interface Init;
		interface Crypto;
	}
	
}
implementation {
	components MainC;   
	components CryptoP;   
	
	MainC.SoftwareInit -> CryptoP.Init;	//auto-initialization
	
	Init = CryptoP.Init;
	Crypto = CryptoP.Crypto;
	
	Crypto.CryptoRaw -> CryptoRawC;
	Crypto.KeyDistrib -> KeyDistribC;
	Crypto.AES -> AESC;
}

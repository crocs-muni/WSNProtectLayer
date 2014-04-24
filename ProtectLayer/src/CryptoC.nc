/** 
 *  Wiring component for cryptographic functions providing Crypto interface via CryptoP implementation.
 *  This component wires CryptoC to implementation from CryptoP and connects to Init interface for automatic initialization.
 *  @version   1.0
 * 	@date      2012-2014
 */
#include "ProtectLayerGlobals.h"
configuration CryptoC {
	provides {
		//interface Init;
		interface Crypto;
	}
	
}
implementation {
	components MainC;   
	components CryptoP; 
	components CryptoRawC;
	components KeyDistribC;
	components AESC;
	components SharedDataC;
	
	MainC.SoftwareInit -> CryptoP.Init;	//auto-initialization phase 1
	
	//Init = CryptoP.Init; 
	Crypto = CryptoP.Crypto;
	
	
	CryptoP.SharedData -> SharedDataC.SharedData;
	CryptoP.CryptoRaw -> CryptoRawC.CryptoRaw;
	CryptoP.KeyDistrib -> KeyDistribC.KeyDistrib;
	CryptoP.AES -> AESC.AES;
	
}

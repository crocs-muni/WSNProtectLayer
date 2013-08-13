/** 
 *  Wiring component for cryptographic functions providing Crypto interface via CryptoP implementation.
 *  This component wires CryptoC to implementation from CryptoP and connects to Init interface for automatic initialization.
 *  @version   0.1
 * 	@date      2012-2013
 */
#include "ProtectLayerGlobals.h"
configuration CryptoC {
	provides {
		interface Crypto;
	}
}
implementation {
	components CryptoP;  
	components RoutingTableC;
	components XXTEAC; 
	components ActiveMessageC;
	components new TimerMilliC() as CurrentTime;
 //   components new TimerMilliC() as CheckDropTimer;
  
  	CryptoP.Packet -> ActiveMessageC.Packet;
  	CryptoP.RoutingTable -> RoutingTableC.RoutingTable;
  	CryptoP.XXTEA -> XXTEAC.XXTEA;
  	CryptoP.CurrentTime -> CurrentTime;
	Crypto = CryptoP.Crypto;
}

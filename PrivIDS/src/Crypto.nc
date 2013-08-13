/** 
 *  Interface for cryptographic functions.
 *  This interface specifies cryptographic functions available in split-phase manner. 
 *  
 *  @version   0.1
 *  @date      2012-2013
 */
#include "ProtectLayerGlobals.h"
interface Crypto {
	
	command error_t depackMsg(am_addr_t dest, message_t * msg, uint8_t * len, uint8_t nonce[NONCE_LEN]);
	
	command void envelopeMsg(am_addr_t dest, message_t * msg, uint8_t * len, uint8_t nonce[NONCE_LEN]);
}

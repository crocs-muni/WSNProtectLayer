/** 
 *  Component providing implementation of Crypto interface.
 *  A module providing actual implementation of Crypto interafce in split-phase manner.
 *  @version   0.1
 * 	@date      2012-2013
 */
#include "ProtectLayerGlobals.h"
#include "aes.h" //AES constants
//#include "printf.h"

module CryptoP {
	
	uses interface CryptoRaw;
	
	provides {
		interface Init;
		interface Crypto;
	}
}
implementation {
	uint8_t 	m_state; 	/**< current state of the component - used to decice on next step inside task */
	PL_key_t* 	m_key1;		/**< handle to the key used as first (or only) one in cryptographic operations. Value is set before task is posted. */
	PL_key_t* 	m_key2;		/**< handle to the key used as second one in cryptographic operations (e.g., deriveKey). Value is set before task is posted. */
	uint8_t* 	m_buffer;	/**< buffer for subsequent encryption or decryption operation. Value is set before task is posted.  */
	uint8_t 	m_bufferTmp[10];	/**< temporary buffer for help with encryption or decryption operation. */
	uint8_t 	m_offset;   /**< offset inside buffer for subsequent encryption or decryption operation. Value is set before task is posted.  */
	uint8_t 	m_len;		/**< length of data inside buffer for subsequent encryption or decryption operation. Value is set before task is posted.  */
	uint16_t	m_dbgKeyID;	/**< unique key id for debugging */
	//
	//	Init interface
	//
	command error_t Init.init() {
                PrintDbg("CryptoP", "Init.init() called.\n");
		// TODO: do other initialization
		m_state = 0;
		m_dbgKeyID = 0;
		return SUCCESS;
	}
	
	command error_t encryptBufferForNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
	//TODO: implement
		return SUCCESS;
	}
	
	command error_t decryptBufferFromNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
	//TODO: implement
		return SUCCESS;
	}
	
	command error_t encryptBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
	//TODO: implement
		return SUCCESS;
	}

	command error_t decryptBufferFromBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
	//TODO: implement
		return SUCCESS;
	}
	
	//will be used??? encrypt/decrypt takes nodeID, not key ...
	command error_t deriveKeyToNodeB( uint8_t nodeID, PL_key_t* derivedKey){
	//TODO: implement
		return SUCCESS;
	}

	command error_t macBufferForNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
	//TODO: implement
		return SUCCESS;
	}	
	
	command error_t macBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
	//TODO: implement
		return SUCCESS;
	}
}

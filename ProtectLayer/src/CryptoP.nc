/** 
 *  Component providing implementation of Crypto interface.
 *  A module providing actual implementation of Crypto interface in split-phase manner.
 *  @version   0.1
 * 	@date      2012-2013
 */
#include "ProtectLayerGlobals.h"
#include "aes.h" //AES constants
//#include "printf.h"

module CryptoP {
	
	uses interface CryptoRaw;
	uses interface KeyDistrib;
	uses interface AES;
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
	uint8_t         exp[240]; //expanded key
	//
	//	Init interface
	//
	command error_t Init.init() {
                PrintDbg("CryptoP", " Init.init() called.\n");
		// TODO: do other initialization
		m_state = 0;
		m_dbgKeyID = 0;
		return SUCCESS;
	}
	
	command error_t protectBufferForNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
		PrintDbg("CryptoP", " protectBufferForNodeB called.\n");
		error_t status = SUCCESS;
	//TODO: implement
	
		status = call macBufferForNodeB(nodeID, buffer, offset, pLen);
		return status;
	}	

	command error_t unprotectBufferFromNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
		PrintDbg("CryptoP", " unprotectBufferFromNodeB called.\n");
	//TODO: implement
		return SUCCESS;
	}		
	
	command error_t protectBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
		PrintDbg("CryptoP", " protectBufferForBSB called.\n");
		error_t status = SUCCESS;
	//TODO: implement
	
		status = call macBufferForBSB(buffer, offset, pLen)
		
		return status;
	}	
	
	command error_t unprotectBufferFromBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
		PrintDbg("CryptoP", " unprotectBufferFromBSB called.\n");
		error_t status = SUCCESS;
	//TODO: implement
		return status;
	}		

	command error_t macBufferForNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
		PrintDbg("CryptoP", " macBufferForNodeB called.\n");
		uint8_t i;
		uint8_t xor[16];
		error_t status = SUCCESS;
		memcpy(xor, buffer + offset, BLOCK_SIZE);
		if((status = call KeyDistrib.getKeyToNodeB( nodeID, m_key1)) == SUCCESS){	
			
			call AES.keyExpansion( exp, m_key1->keyValue);
			
			//process buffer by blocks 
			for(i = 0; i < (pLen / BLOCK_SIZE); i++){
						
				call AES.encrypt( xor, exp, xor);
				for (j := 0; i < BLOCK_SIZE; j++){
					xor[j] = buffer[offset + i + j] ^ xor[j];
				}			
			}
		
		//append mac
		memcpy(buffer + offset + pLen, xor, BLOCK_SIZE);
		} else {
			PrintDbg("CryptoP", " macBufferForNodeB failed, key to nodeID %d not found.\n", nodeID);
		}
		return status;
	}	
	
	command error_t macBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
		PrintDbg("CryptoP", " macBufferForBSB called.\n");
		uint8_t i;
		uint8_t xor[16];
		error_t status = SUCCESS;
		memcpy(xor, buffer + offset, BLOCK_SIZE);
		if((status = call KeyDistrib.getKeyToBSB(m_key1)) == SUCCESS){	
			
			call AES.keyExpansion( exp, m_key1->keyValue);
			
			//process buffer by blocks 
			for(i = 0; i < (pLen / BLOCK_SIZE); i++){
						
				call AES.encrypt( xor, exp, xor);
				for (j := 0; i < BLOCK_SIZE; j++){
					xor[j] = buffer[offset + i + j] ^ xor[j];
				}			
			}
		
		//append mac
		memcpy(buffer + offset + pLen, xor, BLOCK_SIZE);
		} else {			
			PrintDbg("CryptoP", " macBufferForBSB failed, key to BS not found.\n");
		}
		return status;
	}
}

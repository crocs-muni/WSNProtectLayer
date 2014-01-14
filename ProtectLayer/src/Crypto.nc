/** 
 *  Interface for cryptographic functions.
 *  This interface specifies cryptographic functions available in split-phase manner. 
 *  
 *  @version   0.1
 *  @date      2012-2013
 */
#include "ProtectLayerGlobals.h"
interface Crypto {

	//AES encrypt / decrypt buffer for node
	
	//Node variants
	/**
			Command: Blocking version. Used by other components to start encryption of supplied buffer.
			Enough additional space in buffer to fit encrypted content is assumed.
			Function keeps track of couter values for independent nodes.
			@param[in] nodeID node identification of node
			@param[in out] buffer buffer to be encrypted, wil contain encrypted data
			@param[in] offset
			@param[in out] pLen length of buffer to be encrypted, will contain resulting length
			@return error_t status
	*/
	command error_t encryptBufferForNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen);

	/**
			Command: Blocking version. Used by other components to start decryption of supplied buffer.
			Function keeps track of couter values for independent nodes.
			@param[in] nodeID node identification of node			
			@param[in] buffer buffer to be decrypted
			@param[in] offset
			@param[in] len length of buffer to be decrypted
			@return error_t status
	*/
	command error_t decryptBufferFromNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	//BS variants
	/**
			Command: Blocking version. Used by other components to start encryption of supplied buffer from BS.
			Enough additional space in buffer to fit encrypted content is assumed.
			Function keeps track of couter values.
			@param[in out] buffer buffer to be encrypted, wil contain encrypted data
			@param[in] offset
			@param[in out] pLen length of buffer to be encrypted, will contain resulting length
			@return error_t status
	*/
	command error_t encryptBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen);

	/**
			Command: Blocking version. Used by other components to start decryption of supplied buffer from BS.
			Function keeps track of couter values.
			@param[in] buffer buffer to be decrypted
			@param[in] offset
			@param[in] len length of buffer to be decrypted
			@return error_t status
	*/
	command error_t decryptBufferFromBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	//derive key to node
	
	/**
			Command: Used by other components to derive new key from master key and derivation data. 
			@param[in] nodeID node identification of node		
			@param[out] derivedKey resulting derived key
			@return error_t status
	*/	
	//will be used??? encrypt/decrypt takes nodeID, not key ...
	command error_t deriveKeyToNodeB( uint8_t nodeID, PL_key_t* derivedKey);
	
	
	//mac (aes based)
	
	/**
			Command: Blocking version. Used by other components to calculate mac of data for node.
			Enough additional space in buffer to fit mac content is assumed.			
			@param[in] nodeID node identification of node
			@param[in out] buffer buffer for mac calculation, mac will be appended to data
			@param[in] offset
			@param[in out] pLen length of buffer for mac calculation, will contain length with appended mac
			@return error_t status
	*/
	command error_t macBufferForNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	/**
			Command: Blocking version. Used by other components to calculate mac of data for BS.
			Enough additional space in buffer to fit mac content is assumed.			
			@param[in out] buffer buffer for mac calculation, mac will be appended to data
			@param[in] offset
			@param[in out] pLen length of buffer for mac calculation, will contain length with appended mac
			@return error_t status
	*/
	command error_t macBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen);
}

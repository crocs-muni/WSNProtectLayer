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
			In addition function appends mac of encrypted buffer.
			Enough additional space in buffer to fit encrypted content is assumed.
			Function keeps track of couter values for independent nodes.
			@param[in] nodeID node identification of node
			@param[in out] buffer buffer to be encrypted, wil contain encrypted data
			@param[in] offset
			@param[in out] pLen length of buffer to be encrypted, will contain resulting length with mac
			@return error_t status
	*/
	command error_t protectBufferForNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen);

	/**
			Command: Blocking version. Used by other components to start decryption of supplied buffer.
			Function verified appended mac. Function keeps track of couter values for independent nodes.
			@param[in] nodeID node identification of node			
			@param[in] buffer buffer to be decrypted
			@param[in] offset
			@param[in] len length of buffer to be decrypted
			@return error_t status
	*/
	command error_t unprotectBufferFromNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	//BS variants
	/**
			Command: Blocking version. Used by other components to start encryption of supplied buffer from BS.
			In addition function appends mac of encrypted buffer.
			Enough additional space in buffer to fit encrypted content is assumed.
			Function keeps track of couter values.
			@param[in out] buffer buffer to be encrypted, wil contain encrypted data
			@param[in] offset
			@param[in out] pLen length of buffer to be encrypted, will contain resulting length with mac
			@return error_t status
	*/
	command error_t protectBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen);

	/**
			Command: Blocking version. Used by other components to start decryption of supplied buffer from BS.
			Function verified appended mac. Function keeps track of couter values.
			@param[in] buffer buffer to be decrypted
			@param[in] offset
			@param[in] len length of buffer to be decrypted
			@return error_t status
	*/
	command error_t unprotectBufferFromBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	
	//derive key to node	
	/**
			Command: Used by other components to derive new key from master key and derivation data. 
			@param[in] nodeID node identification of node		
			@param[out] derivedKey resulting derived key
			@return error_t status
	*/	
	//probably will not be used because encrypt/decrypt takes nodeID, not key ...
	//command error_t deriveKeyToNodeB( uint8_t nodeID, PL_key_t* derivedKey);
	
	
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
	
	/**
			Command: Blocking version. Used by other components to verify mac of data for node.						
			@param[in] nodeID node identification of node
			@param[in out] buffer buffer containing data and appended mac
			@param[in] offset
			@param[in out] pLen length of buffer with mac
			@return error_t status
	*/
	command error_t verifyMacFromNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	/**
			Command: Blocking version. Used by other components to verify mac of data for BS.
			@param[in out] buffer buffer containing data and appended mac
			@param[in] offset
			@param[in out] pLen length of buffer with mac
			@return error_t status
	*/
	command error_t verifyMacFromBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	/**
			Command: Blocking function to initialize shared keys between nodes.
			Gets nodeID of neighbours from SavedData, for these finds predistributed keys in KDCPrivData.
			derives new shared key and stores key in KDCData.
			@return error_t status
	*/
	command error_t initCryptoIIB();
	
	/**	
			Command: function to calculate AES based hash of data in buffer.
			Resulting hash has AES BLOCK_LENGTH
			@param[in] buffer with data
			@param[in] offset
			@param[in] pLen
			@param[out] hash calculated hash of data
			@return error_t status
	*/
	command error_t hashDataB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint8_t* hash);
		
	/**	
			Command: function to calculate AES based hash of data in buffer.
			Resulting hash has uint64_t format
			@param[in] buffer with data
			@param[in] offset
			@param[in] pLen
			@param[out] hash calculated hash of data
			@return error_t status
	*/
	command error_t hashDataHalfB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint64_t* hash);
	
	/**	
			Command: function to verify hash of data
			@param[in] buffer with data
			@param[in] offset			
			@param[in] pLen
			@param[in] hash to verify
			@return error_t result
	*/
	command error_t verifyHashDataB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint8_t* hash);
	
	/**	
			Command: function to verify first half of hash
			@param[in] buffer with data
			@param[in] offset			
			@param[in] pLen
			@param[in] hash to verify
			@return error_t result
	*/
	command error_t verifyHashDataHalfB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint64_t hash);
	
	/**	
			Command: Command to calculate hash chain of buffer and verifies result of calculation 
			according to privacy level specified.
			@param[in] buffer with data
			@param[in] offset			
			@param[in] pLen
			@param[in] level privacy level
			@param[in] counter number of iterations
			@return bool result true if result matches with value
	*/
	command bool verifySignature( uint8_t* buffer, uint8_t offset, uint8_t pLen, PRIVACY_LEVEL level, uint8_t counter);
	
	/**
			Command: command to execute self test of Crypto component
			@return error_t status
	*/
	command error_t selfTest();
	
}

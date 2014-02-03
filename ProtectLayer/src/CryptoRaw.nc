/** 
 *  Interface for cryptographic functions.
 *  This interface specifies cryptographic functions available in blocking and split-phase manner. 
 *  
 *  @version   0.1
 *  @date      2012-2013
 */
#include "ProtectLayerGlobals.h"
interface CryptoRaw {


	//TODO block size required
	/**
			Command: Blocking version. Used by other components to start encryption of supplied buffer by supplied key.
			Enough additional space in buffer to fit encrypted content is assumed.
			@param[in] key handle to the key that should be used for encryption
			@param[in out] counter counter value before, updated to new value after encryption
			@param[in out] buffer buffer to be encrypted, wil contain encrypted data
			@param[in] offset
			@param[in out] pLen length of buffer to be encrypted, will contain resulting length
			@return error_t status
	*/
	command error_t encryptBufferB(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t pLen);
		
	/**
		Command: Used by other components to derive new key from master key and derivation data. 
		@param[in] masterKey handle to the master key that will be used to derive new one
		@param[in] derivationData buffer containing derivation data
		@param[in] offset offset inside derivationData buffer from which derivation data start
		@param[in] len length of derivation data, should be AES block size
		@param[out] derivedKey resulting derived key
		@return error_t status
	*/	 
	command error_t deriveKeyB(PL_key_t* masterKey, uint8_t* derivationData, uint8_t offset, uint8_t len, PL_key_t* derivedKey);
		
	
	/**	
		Command: function to calculate AES based hash of data in buffer.
		makes one iteration. Length of data is aes block size
		@param[in out] buffer with data, replaced with calculated hash
		@param[in] offset			
		@param[in] key key for encryption
		@param[out] hash calculated value
		@return error_t status
	*/
	command error_t hashDataBlockB( uint8_t* buffer, uint8_t offset, PL_key_t* key, uint8_t* hash);
		
		//TODO documentation 
	command error_t macBuffer(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t* pLen, uint8_t* mac);
	
	/**
		Command: self test of Cryptoraw component
		@return error_t SUCCESS or error message
	*/
	command error_t selfTest();
}
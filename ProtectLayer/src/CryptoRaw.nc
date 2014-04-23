/** 
 *  Interface for cryptographic functions.
 *  This interface specifies cryptographic functions available in blocking manner. 
 *  
 *  @version   1.0
 *  @date      2012-2014
 */
#include "ProtectLayerGlobals.h"
interface CryptoRaw {


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
	command error_t encryptBufferB(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t len);
	
	/**
		Command: Blocking version. Used by other components to start decryption of supplied buffer by supplied key.
		Enough space in buffer to fit decrypted content is assumed.
		Because of use of counter mode, this function uses encrypt buffer function.
		@param[in] key handle to the key that should be used for encryption
		@param[in out] counter counter value before, updated to new value after encryption
		@param[in out] buffer buffer to be encrypted, wil contain encrypted data
		@param[in] offset
		@param[in out] pLen length of buffer to be encrypted, will contain resulting length
		@return error_t status
	*/
	command error_t decryptBufferB(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t len);
		
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
	/**
		Command: Used by Crypto component as inner function for calculating mac of buffer.		
		@param[in] key handle for key, that will be used foe mac calculation
		@param[in] buffer data that will be processed
		@param[in] offset of buffer
		@param[in] pLen length of data in buffer
		@param[out] mac calculated mac of data, space of MAC_LENGTH must be available in memory
		@return error_t status
	*/
	command error_t macBuffer(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t* pLen, uint8_t* mac);
	
	/**
		Command: Used by Crypto component as inner function for verification of mac.
		@param[in] key handle for key, that was used for mac calculation
		@param[in] buffer with original data
		@param[in] offset of buffer
		@param[in] pLen length of data in buffer with mac to verify
		@param[in] mac value that will be verified against supplied data in buffer
		@return error_t status
	*/
	command error_t verifyMac(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	/**
		Command: Used by Crypto component as inner function for mac calculation and encryption of buffer.
		mac is appended to the buffer, so additional space of MAC_LENGTH is required.
		offset can be used for shift of encryption, therefore mac will be calculated from whole payload including header
		but header will stay unecrypted. Mac is calculated first and then is encrypted payload including mac.
		@param[in] key handle for key fro encryption and mac calculation
		@param[in out] buffer with original data
		@param[in] offset of encryption
		@param[in out] pLen length of data, will contain length of data with mac
		@return error_t status
	*/
	command error_t protectBufferB( PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	/**
		Command: Used by Crypto component as inner function for mac verification and decryption of buffer.
		buffer if first decrypted and then if verified mac. If mac does not match, attempt is made to 
		synchronize counter value in range of COUNTER_SYNCHRONIZATION_WINDOW. If synchronization is 
		succesfull, counter is updated to right value. Offset is used to specifie ecryption offset used.
		(i.e. header is not encrypted, but included in mac calculation)
		@param[in] key handle for key for decryption and mac verification
		@param[in out] buffer with original data
		@param[in] offset of encryption
		@param[in] pLen length of data in buffer
		@return error_t status
	*/
	command error_t unprotectBufferB( PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	/**
		Command: self test of Cryptoraw component
		@return error_t SUCCESS or error message
	*/
	command error_t selfTest();
}

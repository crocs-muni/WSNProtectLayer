/** 
 *  Interface for cryptographic functions.
 *  This interface specifies cryptographic functions available in blocking and split-phase manner. 
 *  
 *  @version   0.1
 *  @date      2012-2013
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
	command error_t encryptBufferB(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t* pLen);

	/**
			Command: Blocking version. Used by other components to start decryption of supplied buffer by supplied key.
			@param[in] key handle to the key that should be used for decryption
			@param[in out] counter counter value before, updated to new value after decryption
			@param[in] buffer buffer to be decrypted
			@param[in] len length of buffer to be decrypted
			@return error_t status
	*/
	command error_t decryptBufferB(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t* pLen);
		
		
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
		Command: Used by other components to generate random new key
		@param[in/out] newKey handle to free slot where new key should be generated
		@return error_t status
	*/	
	// IS USED???
	command error_t generateKeyB(PL_key_t* newKey);
	
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
		
		
		
/*** DEPRICATED ***/


	/**
                Command: Split-phase version. Used by other components to start encryption of supplied buffer by supplied key.
		Enough additional space in buffer to fit encrypted comtent is assumed.
		@param[in] key handle to the key that should be used for encryption
                @param[in out] buffer buffer to be encrypted, wil contain encrypted data
		@param[in] len length of buffer to be encrypted 
		@return error_t status
	*/	
	//command error_t encryptBuffer(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t len);
        /**
		Event: Signalized when encryptBuffer task was finished 
		@param[out] status returned by Crypto.encryptBuffer command
		@param[out] buffer encrypted buffer
		@param[out] resultLen length of encrypted data
		@return nothing
	*/	

	//event void encryptBufferDone(error_t status, uint8_t* buffer, uint8_t resultLen);

	/**
		Command: Used by other components to start decryption of supplied buffer by supplied key. 
		@param[in] key handle to the key that should be used for decryption
		@param[in] buffer buffer to be decrypted
		@param[in] len length of buffer to be decrypted 
		@return error_t status
	*/	
	//command error_t decryptBuffer(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t len);
	/**
		Event: Signalized when decryptBuffer task was finished 
		@param[out] status returned by Crypto.decryptBuffer command
		@param[out] buffer decrypted buffer
		@param[out] resultLen length of decrypted data
		@return nothing
	*/	
	//event void decryptBufferDone(error_t status, uint8_t* buffer, uint8_t resultLen);

	/**
		Command: Used by other components to derive new key from master key and derivation data. 
		@param[in] masterKey handle to the master key that will be used to derive new one
		@param[in] derivationData buffer containing derivation data
		@param[in] offset offset inside derivationData buffer from which derivation data start
		@param[in] len length of derivation data
		@return error_t status
	*/	
	//command error_t deriveKey(PL_key_t* masterKey, uint8_t* derivationData, uint8_t offset, uint8_t len, PL_key_t* derivedKey);
	/**
		Event: Signalized when deriveKey task was finished 
		@param[out] status returned by Crypto.deriveKey command
		@param[out] derivedKey handle to newly derived key
		@return nothing
	*/	
	//event void deriveKeyDone(error_t status, PL_key_t* derivedKey);

	/**
		Command: Used by other components to generate random new key
		@param[in] newKey handle to free slot where new key should be generated
		@return error_t status
	*/	
	//command error_t generateKey(PL_key_t* newKey);
	/**
		Event: Signalized when generateKey task was finished 
		@param[out] status returned by Crypto.generateKey command
		@param[out] newKey handle to newly generated key
		@return nothing
	*/	
	//event void generateKeyDone(error_t status, PL_key_t* newKey);


	/**
			Command: Used by other components to generate random new key. Blocking => waits until new key is generated.
			@param[in] newKey handle to free slot where new key should be generated
			@return error_t status
	*/
	//command error_t generateKeyBlocking(PL_key_t* newKey);
}

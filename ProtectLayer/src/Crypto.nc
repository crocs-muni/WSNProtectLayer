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
			Command: Blocking version. Used by other components to calculate mac of buffer and then 
			encrypt it. Offset can be used to shift encryption, i.e. header is included in mac calculation, but 
			is not encrypted. Enough additional space in buffer to fit encrypted content is assumed.
			Function keeps track of couter values for independent nodes.
			@param[in] nodeID node identification of node
			@param[in out] buffer buffer to be encrypted, wil contain encrypted data
			@param[in] offset of encryption
			@param[in out] pLen length of buffer to be encrypted, will contain resulting length with mac
			@return error_t status
	*/	
	command error_t protectBufferForNodeB( node_id_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen);

	/**
			Command: Blocking version. Used by other components to start decryption of supplied buffer.
			Function verifies appended mac. Function keeps track of couter values for independent nodes.
			Function is capable of counter synchronization. Offset can be used for specificaton of used 
			encryption shift (i.e. header was included for mac calculation but not encrypted)
			@param[in] nodeID node identification of node			
			@param[in] buffer buffer to be decrypted
			@param[in] offset
			@param[in] len length of buffer to be decrypted
			@return error_t status
	*/
	command error_t unprotectBufferFromNodeB( node_id_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	//BS variants
	/**
			Command: Blocking version. Used by other components to calculate mac of buffer and then 
			encrypt it for communication with BS. Offset can be used to shift encryption, i.e. header 
			is included in mac calculation, but is not encrypted. Enough additional space in buffer to fit 
			encrypted content is assumed. Function keeps track of couter values for independent nodes.
			@param[in out] buffer buffer to be encrypted, wil contain encrypted data
			@param[in] offset
			@param[in out] pLen length of buffer to be encrypted, will contain resulting length with mac
			@return error_t status
	*/
	command error_t protectBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen);

	/**
			Command: Blocking version. Used by other components to start decryption of supplied buffer received from BS.
			Function verifies appended mac. Function keeps track of couter values for independent nodes.
			Function is capable of counter synchronization. Offset can be used for specificaton of used 
			encryption shift (i.e. header was included for mac calculation but not encrypted)
			@param[in] buffer buffer to be decrypted
			@param[in] offset shift in 
			@param[in] len length of buffer to be decrypted
			@return error_t status
	*/
	command error_t unprotectBufferFromBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	
	
	/**
			Command: Blocking version. Used by other components to calculate mac of data for node.
			Enough additional space in buffer to fit mac content is assumed
			computes mac over supplied buffer, starting from offset with pLen number of bytes
			Note that bytes before offset are not included to mac malculation.
			MAC Length is defined as MAC_LENGTH
			@param[in] nodeID node identification of node
			@param[in out] buffer buffer for mac calculation, mac will be appended to data
			@param[in] offset
			@param[in out] pLen length of buffer starting from offset, mac calculation, will contain length with appended mac
			@return error_t status
	*/
	command error_t macBufferForNodeB(node_id_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
	/**
			Command: Blocking version. Used by other components to calculate mac of data for BS.
			Enough additional space in buffer to fit mac content is assumed.			
			computes mac over supplied buffer, starting from offset with pLen number of bytes
			Note that bytes before offset are not included to mac malculation.
			MAC Length is defined as MAC_LENGTH
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
	command error_t verifyMacFromNodeB( node_id_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen);
	
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
			Output array can be same as input array.
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
	command error_t hashDataShortB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint32_t* hash);
	
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
	command error_t verifyHashDataShortB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint32_t hash);
	
	/**	
			Command: Command to calculate hash chain of buffer and verifies result of calculation 
			according to privacy level specified. Input Length is HASH_LENGTH.
			Optionally returns updated signature, which can be stored using updateSignature function.
			@param[in] buffer with signature to verify
			@param[in] offset
			@param[in] level privacy level
			@param[in] counter supposed placement in hash chain for verified signature, 0 is for predistributed value
			@param[out] signature optional, when not NULL, then filled with updated signature, array must have length of HASH_LENGTH
			@return error_t return verification result. 
	*/
	command error_t verifySignature( uint8_t* buffer, uint8_t offset, PRIVACY_LEVEL level, uint16_t counter, Signature_t* signature);
	
	/**
	                Command: command to update last verified signature stored in memory
	                @param[in] signature value to update, length is required to be HASH_LENGTH
	*/	
	command void updateSignature( Signature_t* signature);
	
	/**
			Command: command to precompute hash chain of signatures. This is intended for BS use only.
			Privacy level of signatures must be specified in first signature supplied in signatures array.
			@param[on out] signatures array of signatures, where at first position is initial signature and rest is filled
			with computed signatures. Must have space for len number of signatures
			@param len total amount of signatures that will be present in signatures array
	*/
	command error_t computeSignature( PRIVACY_LEVEL privacyLevel, uint16_t lenFromRoot, Signature_t* signature);
	/**
			Command: command to execute self test of Crypto component
			@return error_t status
	*/
	command error_t selfTest();
	
}

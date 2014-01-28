/** 
 *  Component providing implementation of Crypto interface.
 *  A module providing actual implementation of Crypto interface in split-phase manner.
 *  @version   0.1
 * 	@date      2012-2013
 */
#include "ProtectLayerGlobals.h"
#include "AES.h" //AES constants

#include "printf.h"

module CryptoP {
	uses {
		interface CryptoRaw;
		interface KeyDistrib;
		interface AES;
		interface SharedData;
	}
	
	provides {
		interface Init;
		interface Crypto;
	}
}
implementation {
	//uint8_t 	m_state; 	/**< current state of the component - used to decice on next step inside task */
	PL_key_t* 	m_key1;		/**< handle to the key used as first (or only) one in cryptographic operations. Value is set before task is posted. */
	PL_key_t* 	m_key2;		/**< handle to the key used as second one in cryptographic operations (e.g., deriveKey). Value is set before task is posted. */
	uint8_t 	m_buffer[BLOCK_SIZE];	/**< buffer for subsequent encryption or decryption operation. Value is set before task is posted.  */
	//uint8_t 	m_bufferTmp[10];	/**< temporary buffer for help with encryption or decryption operation. */
	//uint8_t 	m_offset;   /**< offset inside buffer for subsequent encryption or decryption operation. Value is set before task is posted.  */
	//uint8_t 	m_len;		/**< length of data inside buffer for subsequent encryption or decryption operation. Value is set before task is posted.  */
	//uint16_t	m_dbgKeyID;	/**< unique key id for debugging */
	uint8_t         exp[240]; //expanded key
	//
	//	Init interface
	//
	command error_t Init.init() {
                //PrintDbg("CryptoP", " Init.init() called.\n");
		// TODO: do other initialization
		//m_state = 0;
		//m_dbgKeyID = 0;
		return SUCCESS;
	}
	
	command error_t Crypto.macBufferForNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
		uint8_t i;
		uint8_t j;
		uint8_t xor[16];
		error_t status = SUCCESS;
		
		PrintDbg("CryptoP", " macBufferForNodeB called.\n");
		
		memcpy(xor, buffer + offset, BLOCK_SIZE);
		if((status = call KeyDistrib.getKeyToNodeB( nodeID, m_key1)) == SUCCESS){	
			
			call AES.keyExpansion( exp, (uint8_t*) m_key1->keyValue);
			
			//process buffer by blocks 
			for(i = 0; i < (*pLen / BLOCK_SIZE); i++){
						
				call AES.encrypt( xor, exp, xor);
				for (j = 0; i < BLOCK_SIZE; j++){
					xor[j] = buffer[offset + i + j] ^ xor[j];
				}			
			}
		
			//append mac
			memcpy(buffer+offset+*pLen, xor, BLOCK_SIZE);
		} else {
			PrintDbg("CryptoP", " macBufferForNodeB failed, key to nodeID %X not found.\n", nodeID);
		}
		return status;
	}	
	
	command error_t Crypto.macBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){		
		uint8_t i;
		uint8_t j;
		uint8_t xor[16];
		error_t status = SUCCESS;
		
		PrintDbg("CryptoP", " macBufferForBSB called.\n");
		
		memcpy(xor, buffer + offset, BLOCK_SIZE);
		if((status = call KeyDistrib.getKeyToBSB(m_key1)) == SUCCESS){	
			
			call AES.keyExpansion( exp,  (uint8_t*) m_key1->keyValue);
			
			//process buffer by blocks 
			for(i = 0; i < (*pLen / BLOCK_SIZE); i++){
						
				call AES.encrypt( xor, exp, xor);
				for (j = 0; i < BLOCK_SIZE; j++){
					xor[j] = buffer[offset + i + j] ^ xor[j];
				}			
			}
		
			//append mac
			memcpy(buffer + offset + *pLen, xor, BLOCK_SIZE);
		} else {			
			PrintDbg("CryptoP", " macBufferForBSB failed, key to BS not found.\n");
		}
		return status;
	}
	
	command error_t Crypto.verifyMacFromNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
		uint8_t mac[BLOCK_SIZE];
		error_t status = SUCCESS;
		
		PrintDbg("CryptoP", " verifyMacFromNodeB called.\n");
		
		memcpy(mac, buffer + offset + *pLen - BLOCK_SIZE, BLOCK_SIZE); //copy received mac to temp location
		status = call Crypto.macBufferForNodeB(nodeID, buffer, offset, pLen - BLOCK_SIZE); //calculate new mac
		if((memcmp(mac, buffer + offset + *pLen - BLOCK_SIZE, BLOCK_SIZE))){ //compare new with received
		    status = EWRONGMAC;
		    PrintDbg("CryptoP", " verifyMacFromNodeB message MAC does not match.\n");
		    return status;		
		}
		return status;
	}	
	
	command error_t Crypto.verifyMacFromBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
		uint8_t mac[BLOCK_SIZE];
		error_t status = SUCCESS;
		
		PrintDbg("CryptoP", " verifyMacFromBSB called.\n");
		
		memcpy(mac, buffer + offset + *pLen - BLOCK_SIZE, BLOCK_SIZE); //copy received mac to temp location
		status = call Crypto.macBufferForBSB(buffer, offset, pLen - BLOCK_SIZE); //calculate new mac
		if((memcmp(mac, buffer + offset + *pLen - BLOCK_SIZE, BLOCK_SIZE))){ //compare new with received
		    status = EWRONGMAC;
		    PrintDbg("CryptoP", " verifyMacFromBSB message MAC does not match.\n");
		    return status;		
		}
		return status;
	}	
	
	command error_t Crypto.protectBufferForNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
		error_t status = SUCCESS;		
		
		PrintDbg("CryptoP", " protectBufferForNodeB called.\n");
				
		if((status = call KeyDistrib.getKeyToNodeB( nodeID, m_key1))!= SUCCESS){
			PrintDbg("CryptoP", " protectBufferForNodeB key not retrieved.\n");
			return status;
		}
		if((status = call CryptoRaw.encryptBufferB( m_key1, buffer, offset, *pLen))!= SUCCESS){
			PrintDbg("CryptoP", " protectBufferForNodeB key not retrieved.\n");
			return status;
		}
		if((status = call Crypto.macBufferForNodeB(nodeID, buffer, offset, pLen))!= SUCCESS){
			PrintDbg("CryptoP", " protectBufferForNodeB key not retrieved.\n");
			return status;
		}
		return status;
	}	

	command error_t Crypto.unprotectBufferFromNodeB( uint8_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){		
		error_t status = SUCCESS;		
		
		PrintDbg("CryptoP", " unprotectBufferFromNodeB called.\n");
		if((status = call Crypto.verifyMacFromNodeB(nodeID, buffer, offset, pLen)) != SUCCESS){
			PrintDbg("CryptoP", " unprotectBufferFromNodeB mac verification failed.\n");
			return status;
		}
		if((status = call KeyDistrib.getKeyToNodeB( nodeID, m_key1))!= SUCCESS){	
			PrintDbg("CryptoP", " unprotectBufferFromNodeB key not retrieved.\n");
			return status;
		}
		if((status = call CryptoRaw.decryptBufferB( m_key1, buffer, offset, *pLen))!= SUCCESS){	
			PrintDbg("CryptoP", " unprotectBufferFromNodeB decryption failed.\n");
			return status;
		}
		
		return status;
	}		
	
	command error_t Crypto.protectBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
		error_t status = SUCCESS;		
		
		
		PrintDbg("CryptoP", " protectBufferForBSB called.\n");		
		
		if((status = call KeyDistrib.getKeyToBSB( m_key1)) != SUCCESS){	
			PrintDbg("CryptoP", " protectBufferForBSB key not retrieved.\n");
			return status;		
		}
		if((status = call CryptoRaw.encryptBufferB( m_key1, buffer, offset, *pLen)) != SUCCESS){
			PrintDbg("CryptoP", " protectBufferForBSB encrypt failed.\n");
			return status;		
		}
		if((status = call Crypto.macBufferForBSB( buffer, offset, pLen)) != SUCCESS){
			PrintDbg("CryptoP", " protectBufferForBSB mac failed.\n");
			return status;		
		}
		
		return status;
	}	
	
	command error_t Crypto.unprotectBufferFromBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
		error_t status = SUCCESS;		
				
		PrintDbg("CryptoP", " unprotectBufferFromBSB called.\n");		
		
		if((status = call Crypto.verifyMacFromBSB( buffer, offset, pLen)) != SUCCESS){
			PrintDbg("CryptoP", " unprotectBufferFromBSB mac verification failed.\n");
			return status;
		}
		if((status = call KeyDistrib.getKeyToBSB( m_key1)) != SUCCESS){
			PrintDbg("CryptoP", " unprotectBufferFromBSB BS key not retrieved.\n");
			return status;
		}
		if((status = call CryptoRaw.decryptBufferB( m_key1, buffer, offset, *pLen)) != SUCCESS){
			PrintDbg("CryptoP", " unprotectBufferFromBSB decrypt buffer failed.\n");
			return status;
		}		
		return status;
	}		

	
	
	command error_t Crypto.initCryptoIIB(){
		error_t status = SUCCESS;
		uint16_t copyId;
		SavedData_t* SavedData = NULL;
		KDCPrivData_t* KDCPrivData = NULL;
		SavedData_t* SavedDataEnd = NULL;
		#ifndef max
			#define max( a, b ) ( ((a) > (b)) ? (a) : (b) )
		#endif

		#ifndef min
			#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
		#endif
	
		PrintDbg("CryptoP", " initCryptoIIB called.\n");			
		
		KDCPrivData = call SharedData.getKDCPrivData();
		SavedData = call SharedData.getSavedData();
		if(SavedData == NULL || KDCPrivData == NULL){
		    status = EDATANOTFOUND;
		    return status;
		}
		SavedDataEnd = SavedData + sizeof(SavedData) / sizeof(SavedData[0]);
		//process all saved data items
		while ( SavedData < SavedDataEnd ){
			m_key1 = &(KDCPrivData->preKeys[SavedData->nodeId]); //predistributed key
			
			//get derivation data 
			/*
			calculates derivation data by appending node ID's first lower on, then higher one
			these are appended to array by memcpy and pointer arithmetics ()
			*/
			memset(m_buffer, 0, BLOCK_SIZE); //pad whole block with zeros
			copyId = min(SavedData->nodeId, TOS_NODE_ID);	
			memcpy(m_buffer, &copyId, sizeof(copyId)); 
			copyId = max(SavedData->nodeId, TOS_NODE_ID);
			memcpy(m_buffer + sizeof(copyId), &copyId, sizeof(copyId)); 
			
			//derive key from data and predistributed key
			status = call CryptoRaw.deriveKeyB(m_key1, m_buffer, 0, BLOCK_SIZE, m_key2);
			if(status != SUCCESS){
				PrintDbg("CryptoP", " key derivation for nodeID %x completed with status %x.\n", SavedData->nodeId, status);
			}
			m_key2->counter = 0;
			//save key to KDCData shared key		
			memcpy( &((SavedData->kdcData).shared_key), m_key2, sizeof(PL_key_t));
			
			SavedData++;
		}
		
		return status;
	}
	
	command error_t Crypto.hashDataB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint8_t* hash){
		error_t status = SUCCESS;
		uint8_t i;
		uint8_t j;
		uint8_t tempHash[BLOCK_SIZE];
		
		PrintDbg("CryptoP", " hashDataB called.\n");
		memset(m_key1->keyValue, 0, KEY_SIZE); //init default key value
		for(i = 0; i < pLen/BLOCK_SIZE; i++){
			if((status = call CryptoRaw.hashDataBlockB(buffer, offset + i * BLOCK_SIZE, m_key1, tempHash)) != SUCCESS){
				PrintDbg("CryptoP", " hashDataB calculation failed.\n");
				return status;
			}
			for(j = 0; j < BLOCK_SIZE; j++){
				m_key1->keyValue[j] = tempHash[j] ^ buffer[offset + i * BLOCK_SIZE];
			}
		}
		//pad and calculate last block
		if((pLen % BLOCK_SIZE) == 0){
			for(j = 0; j < BLOCK_SIZE; j++){
				hash[j] = tempHash[j];
			}
		} else {
			for(j = pLen - (pLen % BLOCK_SIZE); j < BLOCK_SIZE; j++){
				buffer[j + offset] = 0;
			}
			if((status = call CryptoRaw.hashDataBlockB(buffer, offset + pLen - (pLen % BLOCK_SIZE), m_key1, hash)) != SUCCESS){
				PrintDbg("CryptoP", " hashDataB calculation failed.\n");
				return status;
			}
		}
		return status;
	}
	
	command error_t Crypto.hashDataHalfB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint64_t* hash){
		uint8_t tempHash[BLOCK_SIZE];
		uint8_t status;
		uint8_t i;
		PrintDbg("CryptoP", "hashDataHalfB called.\n");
		if((status = call Crypto.hashDataB(buffer, offset, pLen, tempHash)) != SUCCESS){
			PrintDbg("CryptoP", "hashDataHalfB calculation failed.\n");
			return status;
		}
		for (i = 0; i < BLOCK_SIZE/2; i++){
			tempHash[i] = tempHash[i]^tempHash[i + BLOCK_SIZE/2];
		}
		memcpy(hash, tempHash, sizeof(hash));
		return SUCCESS;
	}
	
	command error_t Crypto.verifyHashDataB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint8_t* hash){
		error_t status = SUCCESS;
		uint8_t tempHash[BLOCK_SIZE];
		PrintDbg("CryptoP", " verifyHashDataB called.\n");
		if((status = call Crypto.hashDataB(buffer, offset, pLen, tempHash)) != SUCCESS){
			PrintDbg("CryptoP", " verifyHashDataB failed to calculate hash.\n");
		}
		if(memcmp(tempHash, hash, BLOCK_SIZE) != 0){
			PrintDbg("CryptoP", " verifyHashDataB hash not verified.\n");
			return EWRONGHASH;
		}
		return status;
	}
	
	command error_t Crypto.verifyHashDataHalfB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint64_t hash){
		error_t status = SUCCESS;
		uint64_t tempHash;
		PrintDbg("CryptoP", " verifyHashDataB called.\n");
		if((status = call Crypto.hashDataHalfB(buffer, offset, pLen, &tempHash)) != SUCCESS){
			PrintDbg("CryptoP", " verifyHashDataB failed to calculate hash.\n");
		}
		if(tempHash != hash){
			PrintDbg("CryptoP", " verifyHashDataB hash not verified.\n");
			return EWRONGHASH;
		}
		return status;		
	}
	
	command bool Crypto.verifySignature( uint8_t* buffer, uint8_t offset, uint8_t pLen, PRIVACY_LEVEL level, uint8_t counter){
		uint8_t i;
		uint8_t signature[BLOCK_SIZE];
                PrintDbg("CryptoP", " verifySignature called.\n");                
                for(i = 0; i < counter; i++){			
			call Crypto.hashDataB( buffer, offset, pLen, buffer + offset);			
                }
                //call shared data to fill signature
                if(memcmp(buffer + offset, signature, BLOCK_SIZE)){
			return FALSE;
                } else {
			return TRUE;
                }
	}
	
	command error_t Crypto.selfTest(){
		uint8_t status = SUCCESS;
		uint8_t hash[BLOCK_SIZE];
		uint64_t halfHash = 0;
		uint8_t macLength = BLOCK_SIZE;
		PrintDbg("CryptoP", " Self test started.\n");
		memset(m_buffer, 1, BLOCK_SIZE);
		PrintDbg("CryptoP", " hashDataB test started.\n");
		if((status = call Crypto.hashDataB(m_buffer, 0, BLOCK_SIZE, hash)) != SUCCESS){
			PrintDbg("CryptoP", " hashDataB failed.\n");
			return status;
		}		
		if((status = call Crypto.verifyHashDataB(m_buffer, 0, BLOCK_SIZE, hash)) != SUCCESS){
			PrintDbg("CryptoP", " verifyHashDataB failed.\n");
			return status;			
		}
		PrintDbg("CryptoP", " hashDataHalfB started.\n");
		if((status = call Crypto.hashDataHalfB(m_buffer, 0, BLOCK_SIZE, &halfHash)) != SUCCESS){
			PrintDbg("CryptoP", " hashDataHalfB failed.\n");
			return status;		 
		}		
		if((status = call Crypto.verifyHashDataHalfB(m_buffer, 0, BLOCK_SIZE, halfHash)) != SUCCESS){
			PrintDbg("CryptoP", " verifyHashDataB failed.\n");
			return status;
		}
		PrintDbg("CryptoP", " macBufferForBSB started.\n");
		if((status = call Crypto.macBufferForBSB(m_buffer, 0, &macLength)) != SUCCESS){
			  PrintDbg("CryptoP", " macBufferForBSB failed.\n");
			  return status;
		}
		if(macLength != 2 * BLOCK_SIZE){
			PrintDbg("CryptoP", " macBufferForBSB failed to append hash.\n");
			return EWRONGHASH;
		}
		if((status = call Crypto.verifyMacFromBSB(m_buffer, 0, &macLength)) != SUCCESS){
			  PrintDbg("CryptoP", " verifyMacFromBSB failed.\n");
			  return status;
		}
		PrintDbg("CryptoP", " macBufferForNodeB started.\n");
		macLength = BLOCK_SIZE;
		if((status = call Crypto.macBufferForNodeB( 0, m_buffer, 0, &macLength)) != SUCCESS){
			  PrintDbg("CryptoP", " macBufferForNodeB failed.\n");
			  return status;
		}
		if(macLength != 2 * BLOCK_SIZE){
			PrintDbg("CryptoP", " macBufferForNodeB failed to append hash.\n");
			return EWRONGHASH;
		}
		if((status = call Crypto.verifyMacFromNodeB( 0, m_buffer, 0, &macLength)) != SUCCESS){
			  PrintDbg("CryptoP", " verifyMacFromNodeB failed.\n");
			  return status;
		}
		return status;
		
	}	
}

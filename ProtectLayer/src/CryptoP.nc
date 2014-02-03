/** 
 *  Component providing implementation of Crypto interface.
 *  A module providing actual implementation of Crypto interface in split-phase manner.
 *  @version   0.1
 * 	@date      2012-2013
 */
#include "ProtectLayerGlobals.h"
#include "AES.h" //AES constants

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
    
    PL_key_t* 	m_key1;		/**< handle to the key used as first (or only) one in cryptographic operations. Value is set before task is posted. */
    PL_key_t* 	m_key2;		/**< handle to the key used as second one in cryptographic operations (e.g., deriveKey). Value is set before task is posted. */
    uint8_t 	m_buffer[BLOCK_SIZE];	/**< buffer for subsequent encryption or decryption operation. Value is set before task is posted.  */    
    uint8_t         m_exp[240]; //expanded key
    
    // Logging tag for this component
    static const char *TAG = "CryptoP";
    
    //
    //	Init interface
    //
    command error_t Init.init() {        
        // do other initialization        
        return SUCCESS;
    }

    command error_t Crypto.macBufferForNodeB( node_id_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){        
        error_t status = SUCCESS;
        
        pl_log_i(TAG,"CryptoP:  macBufferForNodeB called.\n"); 
        //TODO invalid arguments testing
        if(buffer == NULL){
	    pl_log_e(TAG,"CryptoP: macBufferForNodeB NULL buffer.\n");
	    return FAIL;
        }
        if(pLen == NULL || *pLen == 0){
	    pl_log_e(TAG,"CryptoP: macBufferForNodeB NULL pLen or *pLen = 0.\n");
	    return FAIL;	    
        }
        if(nodeID > 50 || nodeID < 0){
	    pl_log_e(TAG,"CryptoP: macBufferForNodeB wrong nodeID.\n");
	    return FAIL;
        }
        if(offset > 20){
	    pl_log_e(TAG,"CryptoP: macBufferForNodeB offset to large.\n");
	    return FAIL;
        }
        
        if((status = call KeyDistrib.getKeyToNodeB( nodeID, m_key1)) == SUCCESS){
            status = call CryptoRaw.macBuffer(m_key1, buffer, offset, pLen, buffer + offset + *pLen);
        } else {
            pl_log_e(TAG,"CryptoP:  macBufferForNodeB failed, key to nodeID %X not found.\n", nodeID); 
        }
        return status;
    }	
    
    command error_t Crypto.macBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){		
        error_t status = SUCCESS;
        
        pl_log_i(TAG,"CryptoP:  macBufferForBSB called.\n"); 
        if(buffer == NULL){
	    pl_log_e(TAG,"CryptoP: macBufferForNodeB NULL buffer.\n");
	    return FAIL;
        }
        if(pLen == NULL || *pLen == 0){
	    pl_log_e(TAG,"CryptoP: macBufferForNodeB NULL pLen or *pLen = 0.\n");
	    return FAIL;	    
        }        
        if(offset > 20){
	    pl_log_e(TAG,"CryptoP: macBufferForNodeB offset to large.\n");
	    return FAIL;
        }
        
        if((status = call KeyDistrib.getKeyToBSB(m_key1)) == SUCCESS){	
            status = call CryptoRaw.macBuffer(m_key1, buffer, offset, pLen, buffer + offset + *pLen);
        } else {
            pl_log_e(TAG,"CryptoP:  macBufferForNodeB failed, key to BS not found.\n"); 
        }
        return status;        
    }
    
    
    
    command error_t Crypto.verifyMacFromNodeB( node_id_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        uint8_t mac[MAC_LENGTH];
        error_t status = SUCCESS;
        uint8_t newPlen = (*pLen) - MAC_LENGTH;
        
        pl_printf("CryptoP:  verifyMacFromNodeB called.\n"); 
        
        // TODO: verify this condition, may be buggy
        // Check sanity of the input parameters
        if (*pLen < MAC_LENGTH){
        	pl_printf("CryptoP; ERROR; Insane input par. %u %u\n", offset, *pLen);
        	return FAIL;
        }
        
        memcpy(mac, buffer + offset + *pLen - MAC_LENGTH, MAC_LENGTH); //copy received mac to temp location
        status = call Crypto.macBufferForNodeB(nodeID, buffer, offset, &newPlen); //calculate new mac
	
	//TODO revert memcpm condition
        if((memcmp(mac, buffer + offset + *pLen - MAC_LENGTH, MAC_LENGTH))){ //compare new with received
            status = EWRONGMAC;
            
            
            pl_printf("CryptoP:  verifyMacFromNodeB message MAC does not match.\n"); 
            
            
            return status;		
        }
        return status;
    }	
    
    command error_t Crypto.verifyMacFromBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        //TODO: merge with previous
        /*
        uint8_t mac[BLOCK_SIZE];
        error_t status = SUCCESS;
        uint8_t newPlen = (*pLen) - BLOCK_SIZE;

        pl_printf("CryptoP:  verifyMacFromBSB called.\n"); 
        
        //TODO: verify this condition, may be buggy
        // Check sanity of the input parameters
        if (*pLen < BLOCK_SIZE){
        	pl_printf("CryptoP; ERROR; Insane input par. %u %u\n", offset, *pLen);
        	return FAIL;
        }
        
        memcpy(mac, buffer + offset + *pLen - BLOCK_SIZE, BLOCK_SIZE); //copy received mac to temp location
        status = call Crypto.macBufferForBSB(buffer, offset, &newPlen); //calculate new mac
        if((memcmp(mac, buffer + offset + *pLen - BLOCK_SIZE, BLOCK_SIZE))){ //compare new with received
            status = EWRONGMAC;
            
            pl_printf("CryptoP:  verifyMacFromBSB message MAC does not match.\n"); 
            
            
            return status;		
        }
        return status;
        */
    }	
    
    command error_t Crypto.protectBufferForNodeB( node_id_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        error_t status = SUCCESS;	
        
        pl_printf("CryptoP:  protectBufferForNodeB called.\n"); 
        
        //TODO tests and merge with BS version
        
        if((status = call KeyDistrib.getKeyToNodeB( nodeID, m_key1))!= SUCCESS){
            
            pl_printf("CryptoP:  protectBufferForNodeB key not retrieved.\n"); 
            
            return status;
        }
        if((status = call CryptoRaw.encryptBufferB( m_key1, buffer, offset, *pLen))!= SUCCESS){
            //TODO replace messages
            pl_printf("CryptoP:  protectBufferForNodeB key not retrieved.\n"); 
            
            return status;
        }
        if((status = call Crypto.macBufferForNodeB(nodeID, buffer, offset, pLen))!= SUCCESS){
            
            pl_printf("CryptoP:  protectBufferForNodeB key not retrieved.\n"); 
            
            return status;
        }
        
        return status;
    }	
    
    command error_t Crypto.unprotectBufferFromNodeB( node_id_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){		
        error_t status = SUCCESS;		
        
        pl_printf("CryptoP:  unprotectBufferFromNodeB called.\n"); 
        
        
        if((status = call Crypto.verifyMacFromNodeB(nodeID, buffer, offset, pLen)) != SUCCESS){
            
            pl_printf("CryptoP:  unprotectBufferFromNodeB mac verification failed.\n"); 
            
            
            return status;
        }
        if((status = call KeyDistrib.getKeyToNodeB( nodeID, m_key1))!= SUCCESS){	
            
            pl_printf("CryptoP:  unprotectBufferFromNodeB key not retrieved.\n"); 
            
            
            return status;
        }
        if((status = call CryptoRaw.encryptBufferB( m_key1, buffer, offset, *pLen))!= SUCCESS){	
            
            pl_printf("CryptoP:  unprotectBufferFromNodeB decryption failed.\n"); 
            
            
            return status;
        }
        
        return status;
    }		
    
    command error_t Crypto.protectBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        error_t status = SUCCESS;		
        
        
        pl_printf("CryptoP:  protectBufferForBSB called.\n"); 
        
        
        if((status = call KeyDistrib.getKeyToBSB( m_key1)) != SUCCESS){	
            
            pl_printf("CryptoP:  protectBufferForBSB key not retrieved.\n"); 
            
            return status;		
        }
        if((status = call CryptoRaw.encryptBufferB( m_key1, buffer, offset, *pLen)) != SUCCESS){
            
            pl_printf("CryptoP:  protectBufferForBSB encrypt failed.\n"); 
            
            return status;		
        }
        if((status = call Crypto.macBufferForBSB( buffer, offset, pLen)) != SUCCESS){
            
            pl_printf("CryptoP:  protectBufferForBSB mac failed.\n"); 		
                        
            return status;
        }
    }
    
    command error_t Crypto.unprotectBufferFromBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        error_t status = SUCCESS;		
        
        pl_printf("CryptoP:  unprotectBufferFromBSB called.\n"); 
        
        
        if((status = call Crypto.verifyMacFromBSB( buffer, offset, pLen)) != SUCCESS){
            
            pl_printf("CryptoP:  unprotectBufferFromBSB mac verification failed.\n"); 
            
            return status;
        }
        if((status = call KeyDistrib.getKeyToBSB( m_key1)) != SUCCESS){
            
            pl_printf("CryptoP:  unprotectBufferFromBSB BS key not retrieved.\n"); 
            
            return status;
        }
        if((status = call CryptoRaw.encryptBufferB( m_key1, buffer, offset, *pLen)) != SUCCESS){
            
            pl_printf("CryptoP:  unprotectBufferFromBSB decrypt buffer failed.\n"); 
            
            return status;
        }		
        return status;
    }		
    
    
    
    command error_t Crypto.initCryptoIIB(){
        error_t status = SUCCESS;
        uint16_t copyId;
        uint8_t i;
        SavedData_t* SavedData = NULL;
        KDCPrivData_t* KDCPrivData = NULL;
        //SavedData_t* SavedDataEnd = NULL;
#ifndef max
#define max( a, b ) ( ((a) > (b)) ? (a) : (b) )
#endif
        
#ifndef min
#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
#endif
        
        pl_printf("CryptoP:  initCryptoIIB called.\n"); 
        
        KDCPrivData = call SharedData.getKDCPrivData();
        SavedData = call SharedData.getSavedData();
        if(SavedData == NULL || KDCPrivData == NULL){
            status = EDATANOTFOUND;
            //TODO printf()
            return status;
        }
        //SavedDataEnd = SavedData + sizeof(SavedData) / sizeof(SavedData_t);
        //process all saved data items
        //while ( SavedData < SavedDataEnd ){ TODO for cycle
        {
        //TODO function to return prekeys in shared data
            //m_key1 = &(KDCPrivData->preKeys[SavedData->nodeId]); //predistributed key
            //TODO: m_key1 = call savedData.get pre key ...
            //get derivation data 
            /*
            calculates derivation data by appending node ID's first lower on, then higher one
            these are appended to array by memcpy and pointer arithmetics ()
            */
            memset(m_buffer, 0, BLOCK_SIZE); //pad whole block with zeros
            copyId = min(SavedData[i].nodeId, TOS_NODE_ID);	
            memcpy(m_buffer, &copyId, sizeof(copyId)); 
            copyId = max(SavedData[i].nodeId, TOS_NODE_ID);
            memcpy(m_buffer + sizeof(copyId), &copyId, sizeof(copyId)); 
            
            //derive key from data and predistributed key
            status = call CryptoRaw.deriveKeyB(m_key1, m_buffer, 0, BLOCK_SIZE, m_key2);
            if(status != SUCCESS){
                
                pl_printf("CryptoP:  key derivation for nodeID %x completed with status %x.\n", SavedData->nodeId, status); 
                
            }
            m_key2->counter = 0;
            //save key to KDCData shared key		
            memcpy( &((SavedData[i].kdcData).shared_key), m_key2, sizeof(PL_key_t));
            
            //SavedData++;
        }
        
        return status;
    }
    //TODO merge hash with mac
    command error_t Crypto.hashDataB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint8_t* hash){
        error_t status = SUCCESS;
        uint8_t i;
        uint8_t j;
        uint8_t tempHash[BLOCK_SIZE];
        
        pl_printf("CryptoP:  hashDataB called.\n"); 
        //TODO arguments tests
        
        //TODO add function to set default hash key
        memset(m_key1->keyValue, 0, KEY_SIZE); //init default key value
        for(i = 0; i < pLen/BLOCK_SIZE; i++){
        //TODO check for incomplete block
            if((status = call CryptoRaw.hashDataBlockB(buffer, offset + i * BLOCK_SIZE, m_key1, tempHash)) != SUCCESS){
                
                pl_printf("CryptoP:  hashDataB calculation failed.\n"); 
                
                return status;
            }
            //TODO hash size constant
            for(j = 0; j < BLOCK_SIZE; j++){
                m_key1->keyValue[j] = tempHash[j];
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
                
                pl_printf("CryptoP:  hashDataB calculation failed.\n"); 
                
                return status;
            }
        }
        return status;
    }
    
    //TODO change header and define short hash as constant
    command error_t Crypto.hashDataShortB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint32_t* hash){
        uint8_t tempHash[BLOCK_SIZE];
        uint8_t status;
        uint8_t i;
        
        //TODO checks
        pl_printf("CryptoP: hashDataHalfB called.\n"); 
        
        if((status = call Crypto.hashDataB(buffer, offset, pLen, tempHash)) != SUCCESS){
            
            pl_printf("CryptoP: hashDataHalfB calculation failed.\n"); 
            
            return status;
        }
        for (i = 0; i < BLOCK_SIZE/4; i++){
            tempHash[i] = tempHash[i]^tempHash[i + BLOCK_SIZE/2];
        }
        memcpy(hash, tempHash, sizeof(*hash));
        return SUCCESS;
    }
    
    command error_t Crypto.verifyHashDataB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint8_t* hash){
        error_t status = SUCCESS;
        uint8_t tempHash[BLOCK_SIZE];
        
        pl_printf("CryptoP:  verifyHashDataB called.\n"); 
        
        if((status = call Crypto.hashDataB(buffer, offset, pLen, tempHash)) != SUCCESS){
            
            pl_printf("CryptoP:  verifyHashDataB failed to calculate hash.\n"); 
            
        }
        if(memcmp(tempHash, hash, BLOCK_SIZE) != 0){
            
            pl_printf("CryptoP:  verifyHashDataB hash not verified.\n"); 
            
            return EWRONGHASH;
        }
        return status;
    }
    
    command error_t Crypto.verifyHashDataShortB( uint8_t* buffer, uint8_t offset, uint8_t pLen, uint32_t hash){
        error_t status = SUCCESS;
        uint32_t tempHash;
        
        pl_printf("CryptoP:  verifyHashDataB called.\n"); 
        
        if((status = call Crypto.hashDataShortB(buffer, offset, pLen, &tempHash)) != SUCCESS){
            
            pl_printf("CryptoP:  verifyHashDataB failed to calculate hash.\n"); 
            
        }
        if(tempHash != hash){
            
            pl_printf("CryptoP:  verifyHashDataB hash not verified.\n"); 
            
            return EWRONGHASH;
        }
        return status;		
    }
    
    //TODO add function for update signature value
    
    //TODO uint16_t counter
    command bool Crypto.verifySignature( uint8_t* buffer, uint8_t offset, uint8_t pLen, PRIVACY_LEVEL level, uint16_t counter, uint8_t* signature){
    //TODO add optional rparameter for signature return
        uint16_t i;
        uint8_t tmpSignature[HASH_LENGTH];
        
        pl_printf("CryptoP:  verifySignature called.\n"); 
        
        for(i = 0; i < counter; i++){			
            call Crypto.hashDataB( buffer, offset, pLen, buffer + offset);			
        }
        //TODO call shared data to fill signature
        //TODO memcmp change condition
        if(memcmp(buffer + offset, tmpSignature, BLOCK_SIZE)){
            return FALSE;
        } else {
            return TRUE;
        }
    }
    
    command void Crypto.updateSignature( uint8_t signature){
        //TODO implementation
    }
    
    command error_t Crypto.selfTest(){
        uint8_t status = SUCCESS;
        uint8_t hash[BLOCK_SIZE];
        uint32_t halfHash = 0;
        uint8_t macLength = BLOCK_SIZE;
        
        pl_printf("CryptoP:  Self test started.\n"); 
        
        memset(m_buffer, 1, BLOCK_SIZE);
        
        pl_printf("CryptoP:  hashDataB test started.\n"); 
        
        if((status = call Crypto.hashDataB(m_buffer, 0, BLOCK_SIZE, hash)) != SUCCESS){
            
            pl_printf("CryptoP:  hashDataB failed.\n"); 
            
            return status;
        }		
        if((status = call Crypto.verifyHashDataB(m_buffer, 0, BLOCK_SIZE, hash)) != SUCCESS){
            
            pl_printf("CryptoP:  verifyHashDataB failed.\n"); 
            
            return status;			
        }
        
        pl_printf("CryptoP:  hashDataHalfB started.\n"); 
        
        if((status = call Crypto.hashDataShortB(m_buffer, 0, BLOCK_SIZE, &halfHash)) != SUCCESS){
            
            pl_printf("CryptoP:  hashDataHalfB failed.\n"); 
            
            return status;		 
        }		
        if((status = call Crypto.verifyHashDataShortB(m_buffer, 0, BLOCK_SIZE, halfHash)) != SUCCESS){
            
            pl_printf("CryptoP:  verifyHashDataB failed.\n"); 
            
            return status;
        }
        
        pl_printf("CryptoP:  macBufferForBSB started.\n"); 
        
        if((status = call Crypto.macBufferForBSB(m_buffer, 0, &macLength)) != SUCCESS){
            
            pl_printf("CryptoP:  macBufferForBSB failed.\n"); 
            
            
            return status;
        }
        if(macLength != 2 * BLOCK_SIZE){
            
            pl_printf("CryptoP:  macBufferForBSB failed to append hash.\n"); 
            
            return EWRONGHASH;
        }
        if((status = call Crypto.verifyMacFromBSB(m_buffer, 0, &macLength)) != SUCCESS){
            
            
            pl_printf("CryptoP:  verifyMacFromBSB failed.\n"); 
            
            return status;
        }
        
        pl_printf("CryptoP:  macBufferForNodeB started.\n"); 
        
        macLength = BLOCK_SIZE;
        if((status = call Crypto.macBufferForNodeB( 0, m_buffer, 0, &macLength)) != SUCCESS){
            
            pl_printf("CryptoP:  macBufferForNodeB failed.\n"); 
            
            return status;
        }
        if(macLength != 2 * BLOCK_SIZE){
            
            pl_printf("CryptoP:  macBufferForNodeB failed to append hash.\n"); 
            
            return EWRONGHASH;
        }
        if((status = call Crypto.verifyMacFromNodeB( 0, m_buffer, 0, &macLength)) != SUCCESS){
            
            pl_printf("CryptoP:  verifyMacFromNodeB failed.\n"); 
            
            
            return status;
        }
        return status;
    }
}



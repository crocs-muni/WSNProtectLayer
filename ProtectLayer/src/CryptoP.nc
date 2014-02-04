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
        
        if((status = call KeyDistrib.getKeyToBSB(m_key1)) == SUCCESS){	
            status = call CryptoRaw.macBuffer(m_key1, buffer, offset, pLen, buffer + offset + *pLen);
        } else {
            pl_log_e(TAG,"CryptoP:  macBufferForNodeB failed, key to BS not found.\n"); 
        }
        return status;        
    }
    
    command error_t Crypto.verifyMacFromNodeB( node_id_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        error_t status = SUCCESS;        
        
        pl_printf("CryptoP:  verifyMacFromNodeB called.\n"); 
                
        if((status = call KeyDistrib.getKeyToNodeB(nodeID, m_key1)) != SUCCESS){
	   pl_log_e(TAG,"CryptoP:  macBufferForNodeB failed, key to node not found.\n"); 
	}
        status = call CryptoRaw.verifyMac(m_key1, buffer,  offset, pLen);
        return status;
    }	
    
    command error_t Crypto.verifyMacFromBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
       error_t status = SUCCESS;        
        
        pl_printf("CryptoP:  verifyMacFromBSB called.\n"); 
                
        if((status = call KeyDistrib.getKeyToBSB( m_key1)) != SUCCESS){
	   pl_log_e(TAG,"CryptoP:  macBufferForBSB failed, key to BS not found.\n"); 
	}
        status = call CryptoRaw.verifyMac(m_key1, buffer,  offset, pLen);
        return status;
    }	
    
    command error_t Crypto.protectBufferForNodeB( node_id_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        error_t status = SUCCESS;	
        
        pl_printf("CryptoP:  protectBufferForNodeB called.\n"); 

        if((status = call KeyDistrib.getKeyToNodeB( nodeID, m_key1))!= SUCCESS){
            pl_printf("CryptoP:  protectBufferForNodeB key not retrieved.\n");
            return status;
        }
        status = call CryptoRaw.protectBufferB( m_key1, buffer, offset, pLen);
        
        return status;
    }	
    
    command error_t Crypto.unprotectBufferFromNodeB( node_id_t nodeID, uint8_t* buffer, uint8_t offset, uint8_t* pLen){		
        error_t status = SUCCESS;		
        
        pl_printf("CryptoP:  unprotectBufferFromNodeB called.\n"); 
       
        if((status = call KeyDistrib.getKeyToNodeB( nodeID, m_key1))!= SUCCESS){
            pl_printf("CryptoP:  unprotectBufferFromNodeB key not retrieved.\n");
            return status;
        }
       
        status = call CryptoRaw.unprotectBufferB( m_key1, buffer, offset, pLen);
        return status;
    }		
    
    command error_t Crypto.protectBufferForBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        error_t status = SUCCESS;	
        
        pl_printf("CryptoP:  protectBufferForBSB called.\n"); 

        if((status = call KeyDistrib.getKeyToBSB( m_key1))!= SUCCESS){
            pl_printf("CryptoP:  protectBufferForBSB key not retrieved.\n");
            return status;
        }
        status = call CryptoRaw.protectBufferB( m_key1, buffer, offset, pLen);
        
        return status;
    }
    
    command error_t Crypto.unprotectBufferFromBSB( uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        error_t status = SUCCESS;		
        
        pl_printf("CryptoP:  unprotectBufferBSB called.\n"); 
       
        if((status = call KeyDistrib.getKeyToBSB( m_key1))!= SUCCESS){
            pl_printf("CryptoP:  unprotectBufferFromBSB key not retrieved.\n");
            return status;
        }
       
        status = call CryptoRaw.unprotectBufferB( m_key1, buffer, offset, pLen);
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
            pl_log_f(TAG, "CryptoP initialization cannot acces predistributed data.\n");
            return status;
        }
        for(i = 0; i < MAX_NEIGHBOR_COUNT; i++){
            m_key1 = call SharedData.getPredistributedKeyForNode(i);
	    if(m_key1 == NULL){
		pl_log_e(TAG, "CryptoP:  predistributed key for node %x not retrieved.\n", i); 
                continue;
	    }
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
                pl_log_e(TAG, "CryptoP:  key derivation for nodeID %x completed with status %x.\n", SavedData->nodeId, status); 
                continue;
            }
            m_key2->counter = 0;
            //save key to KDCData shared key		
            memcpy( &((SavedData[i].kdcData).shared_key), m_key2, sizeof(PL_key_t));
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
    
    command void Crypto.updateSignature( uint8_t* signature,  PRIVACY_LEVEL level){
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



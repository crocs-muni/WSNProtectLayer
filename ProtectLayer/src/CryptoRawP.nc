/** 
 *  Component providing implementation of CryptoRaw interface.
 *  A module providing actual implementation of CryptoRaw interafce in split-phase manner.
 *  @version   0.1
 * 	@date      2012-2013
 */
#include "ProtectLayerGlobals.h"
#include "AES.h" //AES constants

module CryptoRawP {
    
    //added AES
    uses interface AES;
    
    provides {
        interface Init;
        interface CryptoRaw;
    }
}
implementation {
    
    PL_key_t* 	m_key1;		/**< handle to the key used as first (or only) one in cryptographic operations. Value is set before task is posted. */
    PL_key_t* 	m_key2;		/**< handle to the key used as second one in cryptographic operations (e.g., deriveKey). Value is set before task is posted. */
    uint8_t         m_exp[240]; //expanded key
    
    static const char *TAG = "CryptoRawP";
    
    //
    //	Init interface
    //
    command error_t Init.init() {
       
        return SUCCESS;
    }
    
    //
    //	CryptoRaw interface
    //	

    command error_t CryptoRaw.encryptBufferB(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t len) {
        uint8_t i;
        uint8_t j;
        uint8_t plainCounter[BLOCK_SIZE];			
        uint8_t encCounter[BLOCK_SIZE];

        pl_log_d(TAG,"CryptoRawP: encryptBufferB(buffer = '0x%x', 1 = '0x%x', 2 = '0x%x'.\n", buffer[0],buffer[1],buffer[2]);

        if(key == NULL){
	    pl_log_e(TAG,"CryptoRawP: encryptBufferB NULL key.\n");
	    return FAIL;	    
        }
        if(buffer == NULL){
	    pl_log_e(TAG,"CryptoRawP: encryptBufferB NULL buffer.\n");
	    return FAIL;	    
        }
        if(offset > MAX_OFFSET){
	    pl_log_e(TAG,"CryptoRawP: encryptBufferB offset is larger than max.\n");
	    return FAIL;	    
        }
        if(len == 0){
	    pl_log_e(TAG,"CryptoRawP: encryptBufferB pLen = 0.\n");
	    return FAIL;	    
        }
        
        //set rest of counter to zeros to fit AES block
        memset(plainCounter, 0, BLOCK_SIZE);	
        
        call AES.keyExpansion( m_exp, (uint8_t*) key->keyValue);
        
        //process buffer by blocks 
        for(i = 0; i < (len / BLOCK_SIZE) + 1; i++){
           
            plainCounter[0] =  key->counter;
            plainCounter[1] =  (key->counter) >> 8;
            plainCounter[2] =  (key->counter) >> 16;
            plainCounter[3] =  (key->counter) >> 24;
            call AES.encrypt( plainCounter, m_exp, encCounter);
            
            for (j = 0; j < BLOCK_SIZE; j++){
                if( i*BLOCK_SIZE + j > len) break;
                buffer[offset + i*BLOCK_SIZE + j] ^= encCounter[j];
            }
            (key->counter)++;
            if((key->counter) == 0){
                
                pl_log_i(TAG,"CryptoRawP:  encryptBufferB counter overflow, generate new key requiered.\n"); 
                
                //deal with new key and counter value reset
            }
        }
        return SUCCESS;
    }
    
    command error_t CryptoRaw.decryptBufferB(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t len) {
        //for counter mode encrypt is same es decrypt
        return call CryptoRaw.encryptBufferB(key, buffer, offset, len);
    }
    
    command error_t CryptoRaw.macBuffer(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t* pLen, uint8_t* mac){
	uint8_t i;
        uint8_t j;
        uint8_t xor[BLOCK_SIZE];
        error_t status = SUCCESS;
        
        pl_log_d(TAG,"CryptoRawP: macBuffer called.\n");
        if(key == NULL){
	    pl_log_e(TAG,"CryptoRawP: macBuffer NULL key.\n");
	    return FAIL;	    
        }
        if(buffer == NULL){
	    pl_log_e(TAG,"CryptoRawP: macBuffer NULL buffer.\n");
	    return FAIL;	    
        }
        if(offset > MAX_OFFSET){
	    pl_log_e(TAG,"CryptoRawP: macBuffer offset is larger than max.\n");
	    return FAIL;	    
        }
        if(pLen == NULL || *pLen == 0){
	    pl_log_e(TAG,"CryptoRawP: macBuffer NULL pLen or *pLen = 0.\n");
	    return FAIL;	    
        }
        if(mac == NULL){
	    pl_log_e(TAG,"CryptoRawP: macBuffer NULL output mac.\n");
	    return FAIL;	    
        }
        
        call AES.keyExpansion( m_exp, key->keyValue);
            
            //if pLen is < BLOCK_SIZE then copy just pLen otherwise copy first block of data
            memset(xor, 0, BLOCK_SIZE);
            if(*pLen < BLOCK_SIZE){
                memcpy(xor, buffer + offset, *pLen);
            } else {
                memcpy(xor, buffer + offset, BLOCK_SIZE);
            }
            //process buffer by blocks 
            for(i = 0; i < (*pLen / BLOCK_SIZE) + 1; i++){
                
                call AES.encrypt( xor, m_exp, xor);
                for (j = 0; j < BLOCK_SIZE; j++){
                
		    if((*pLen <= (i*BLOCK_SIZE+j))) break;
                    xor[j] =  buffer[offset + i*BLOCK_SIZE + j] ^ xor[j];
                }			
            }
            //output mac
            memcpy(mac, xor, BLOCK_SIZE);        
        
        return status;
    }
    
    command error_t CryptoRaw.verifyMac(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        uint8_t mac[MAC_LENGTH];
        error_t status = SUCCESS;        
        
        pl_printf("CryptoP:  verifyMac called.\n"); 
        
        // Check sanity of the input parameters
         if(key == NULL){
	    pl_log_e(TAG,"CryptoP: verifyMac NULL key.\n");
	    return FAIL;
        }
        if(buffer == NULL){
	    pl_log_e(TAG,"CryptoP: verifyMac NULL buffer.\n");
	    return FAIL;
        }
        if(offset > MAX_OFFSET){
	    pl_log_e(TAG,"CryptoP: verifyMac offset is larger than max.\n");
	    return FAIL;
        }
        if(pLen == NULL){
	    pl_log_e(TAG,"CryptoP: verifyMac pLen NULL.\n");
	    return FAIL;
        }
        if (*pLen < MAC_LENGTH){
            pl_log_e(TAG,"CryptoP; input len smaller than mac length. %u\n", *pLen);
            return FAIL;
        }
        
        status = call CryptoRaw.macBuffer(key, buffer, offset, pLen, mac); //calculate new mac	
	
        if((memcmp(mac, buffer + offset + *pLen - MAC_LENGTH, MAC_LENGTH)) != 0){ //compare new with received
            status = EWRONGMAC;            
            pl_log_e(TAG,"CryptoP:  verifyMacFromNodeB message MAC does not match.\n"); 
            return status;
        }
        return status;
    }
    
    
    command error_t CryptoRaw.deriveKeyB(PL_key_t* masterKey, uint8_t* derivationData, uint8_t offset, uint8_t len, PL_key_t* derivedKey) {
        
         pl_log_d(TAG, "CryptoRawP: deriveKeyB called.\n"); 
        
        if(masterKey == NULL){
	    pl_log_e(TAG,"CryptoRawP: deriveKeyB NULL masterKey.\n");
	    return FAIL;	    
        }
        if(derivationData == NULL){
	    pl_log_e(TAG,"CryptoRawP: deriveKeyB NULL derivationData.\n");
	    return FAIL;	    
        }        
        if(offset > MAX_OFFSET){
	    pl_log_e(TAG,"CryptoRawP: deriveKeyB offset is larger than max.\n");
	    return FAIL;	    
        }        
        if(len != BLOCK_SIZE){
	    pl_log_e(TAG,"CryptoRawP: deriveKeyB len != BLOCK_SIZE.\n");
	    return FAIL;	    
        }        
        if(derivedKey == NULL){
	    pl_log_e(TAG,"CryptoRawP: deriveKeyB NULL derivedKey.\n");
	    return FAIL;	    
        }
        
        call AES.keyExpansion( m_exp, (uint8_t*)(masterKey->keyValue));
        call AES.encrypt( derivationData + offset, m_exp, (uint8_t*)(derivedKey->keyValue));		
        
        return SUCCESS;
    }
   
    command error_t CryptoRaw.hashDataBlockB( uint8_t* buffer, uint8_t offset, PL_key_t* key, uint8_t* hash){
        error_t status = SUCCESS;		
        uint8_t i;
        
        pl_log_d(TAG,"CryptoRawP:  hashDataBlockB called.\n");

        if(buffer == NULL){
	    pl_log_e(TAG,"CryptoRawP: hashDataBlockB NULL buffer.\n");
	    return FAIL;	    
        }
        if(offset > MAX_OFFSET){
	    pl_log_e(TAG,"CryptoRawP: hashDataBlockB offset is larger than max.\n");
	    return FAIL;	    
        }
        if(key == NULL){
	    pl_log_e(TAG,"CryptoRawP: hashDataBlockB NULL key.\n");
	    return FAIL;	    
        }
        if(hash == NULL){
	    pl_log_e(TAG,"CryptoRawP: hashDataBlockB NULL hash.\n");
	    return FAIL;	    
        }
       
       
        call AES.keyExpansion( m_exp, (uint8_t*) key->keyValue);		
        call AES.encrypt( hash, m_exp, buffer + offset);
        for(i = 0; i < BLOCK_SIZE; i++){
            hash[i] = buffer[i + offset] ^ hash[i];
        }		
        return status;
    }
    
    
    command error_t CryptoRaw.protectBufferB( PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        error_t status = SUCCESS;
        if(key == NULL){
	    pl_log_e(TAG,"CryptoRawP: protectBufferB NULL key.\n");
	    return FAIL;	    
        }
        if(buffer == NULL){
	    pl_log_e(TAG,"CryptoRawP: protectBufferB NULL buffer.\n");
	    return FAIL;	    
        }
        if(offset > MAX_OFFSET){
	    pl_log_e(TAG,"CryptoRawP: protectBufferB offset is larger than max.\n");
	    return FAIL;	    
        }
        if(pLen == NULL || *pLen == 0){
	    pl_log_e(TAG,"CryptoRawP: protectBufferB NULL pLen || *pLen == 0.\n");
	    return FAIL;	    
        }
        
        //offset is used for encryption shift, to mac, but not encrypt SPheader
        if((status = call CryptoRaw.macBuffer(key, buffer, 0, pLen, buffer + *pLen)) != SUCCESS){
            pl_printf("CryptoP:  protectBufferForBSB mac failed.\n");
            return status;
        }
        if((status = call CryptoRaw.encryptBufferB( key, buffer, offset, *pLen)) != SUCCESS){
            pl_printf("CryptoP:  protectBufferForBSB encrypt failed.\n");
            return status;		
        }
        return status;
    }
	
    command error_t CryptoRaw.unprotectBufferB( PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        error_t status = SUCCESS;
        uint8_t i;
        uint32_t counter = key->counter;
        pl_log_d( TAG, "CryptoP unprotectBufferB called.\n");
        //offset is used for encryption shift, to verify SPheader, but not to encrypt it

        if((status = call CryptoRaw.decryptBufferB( key, buffer, offset, *pLen)) != SUCCESS){
            pl_log_e( TAG, "CryptoP:  unprotectBufferB encrypt failed.\n");
            return status;		
        }
        if((status = call CryptoRaw.verifyMac( key, buffer, 0, pLen)) != SUCCESS){            
            pl_log_e( TAG, "CryptoP:  unprotectBufferB mac verification failed, trying to sychronize counter.\n"); 
            for (i = 1; i <= COUNTER_SYNCHRONIZATION_WINDOW; i++){
		
		key->counter = counter - i;
		call CryptoRaw.decryptBufferB( key, buffer, offset, *pLen);
		if((status = call CryptoRaw.verifyMac( key, buffer, 0, pLen)) == SUCCESS){
		    pl_log_i( TAG, "CryptoP counter synchronization succesfull.\n");
		    return status;
		}
		
                key->counter = counter + i;
		call CryptoRaw.decryptBufferB( key, buffer, offset, *pLen);
		if((status = call CryptoRaw.verifyMac( key, buffer, 0, pLen)) == SUCCESS){
		    pl_log_i( TAG, "CryptoP counter synchronization succesfull.\n");
		    return status;
		}
            }
            pl_log_e(TAG, "CryptoP counter could not be sychronized, decrypt failed.\n");
            key->counter = counter;
            return status;
        }
        return status;
    }
    
    command error_t CryptoRaw.selfTest(){
        uint8_t data[BLOCK_SIZE] = {0};
        uint8_t i;
        uint8_t status = SUCCESS;
        
        pl_printf("CryptoRawP:  self test started.\n");         
        memset(m_key1->keyValue, 0, KEY_SIZE);
        m_key1->counter = 0;        
        pl_printf("CryptoRawP:  self test encrypt.\n"); 
        
        if((status = call CryptoRaw.encryptBufferB( m_key1, data, 0, BLOCK_SIZE)) != SUCCESS){            
            pl_printf("CryptoRawP:  self test encrypt return failed.\n");             
            return status;
        }
        if(m_key1->counter != 1){            
            pl_printf("CryptoRawP:  self test encrypt counter not incremented.\n");             
            return  EINVALIDDECRYPTION;
        } else {
            m_key1->counter = 0;
        }
        
        pl_printf("CryptoRawP:  self test derive key.\n");         
        if((status = call CryptoRaw.deriveKeyB(m_key1, data, 0, BLOCK_SIZE, m_key2))!= SUCCESS){            
            pl_printf("CryptoRawP:  self test derive key failed.\n");             
            return status;
        }
        if(memcmp(m_key1, m_key2, sizeof(m_key1))){            
            pl_printf("CryptoRawP:  self test derive key, derived key is same as master.\n");             
            return  EDIFFERENTKEY;
        }
        for(i = 0; i < KEY_SIZE; i++){
            if(m_key1->keyValue[i] == 0){                
                pl_printf("CryptoRawP:  self test derive key, derived key is all zeros.\n");                 
                return EDIFFERENTKEY;
            }
        }
        return status;
    }
}

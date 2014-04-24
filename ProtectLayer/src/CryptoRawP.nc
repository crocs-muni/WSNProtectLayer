/** 
 *  Component providing implementation of CryptoRaw interface.
 *  A module providing actual implementation of CryptoRaw interafce in split-phase manner.
 *  @version   1.0
 * 	@date      2012-2014
 */
#include "ProtectLayerGlobals.h"
#include "AES.h" //AES constants

#define SKIP_SELECTED_CRYPTO_RAW_MESSAGES


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

    error_t verifyArguments(char* fncName, PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t len, uint8_t* mac) {
        if(key == NULL){
#ifndef SKIP_SELECTED_CRYPTO_RAW_MESSAGES
	    pl_log_e( TAG," %s NULL key.\n",fncName);
#endif
	    return FAIL;	    
        }
        if(buffer == NULL){
#ifndef SKIP_SELECTED_CRYPTO_RAW_MESSAGES
	    pl_log_e( TAG," %s  NULL buffer.\n", fncName);
#endif
	    return FAIL;	    
        }
        if(offset > MAX_OFFSET){
#ifndef SKIP_SELECTED_CRYPTO_RAW_MESSAGES
	    pl_log_e( TAG," %s  offset is larger than max.\n", fncName);
#endif
	    return FAIL;	    
        }
        if(len == 0){
#ifndef SKIP_SELECTED_CRYPTO_RAW_MESSAGES
	    pl_log_e( TAG," %s  len = 0.\n", fncName);
#endif
	    return FAIL;	    
        }

        if(mac == NULL){
#ifndef SKIP_SELECTED_CRYPTO_RAW_MESSAGES
	    pl_log_e( TAG," %s NULL output mac.\n", fncName);
#endif
	    return FAIL;	    
        }
	return SUCCESS;
    } 	

    #define FAKE_PTR (uint8_t*) 0xbaadf00d	
    error_t verifyArgumentsShort(char* fncName, PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t len) {
    	return verifyArguments(fncName, key, buffer, offset, len, FAKE_PTR);
    }

    
    //
    //	CryptoRaw interface
    //	

    command error_t CryptoRaw.encryptBufferB(PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t len) {
        uint8_t i;
        uint8_t j;
        uint8_t plainCounter[BLOCK_SIZE];			
        uint8_t encCounter[BLOCK_SIZE];

        pl_log_d( TAG," encryptBufferB(buffer = '0x%x', 1 = '0x%x', 2 = '0x%x'.\n", buffer[0],buffer[1],buffer[2]);

	if (verifyArgumentsShort("encryptBufferB", key, buffer, offset, len) == FAIL) {
	    return FAIL;
        }
/*
        if(key == NULL){
	    pl_log_e( TAG," encryptBufferB NULL key.\n");
	    return FAIL;	    
        }
        if(buffer == NULL){
	    pl_log_e( TAG," encryptBufferB NULL buffer.\n");
	    return FAIL;	    
        }
        if(offset > MAX_OFFSET){
	    pl_log_e( TAG," encryptBufferB offset is larger than max.\n");
	    return FAIL;	    
        }
        if(len == 0){
	    pl_log_e( TAG," encryptBufferB pLen = 0.\n");
	    return FAIL;	    
        }
*/        
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
                if (i*BLOCK_SIZE + j >= len) break;
                buffer[offset + i*BLOCK_SIZE + j] ^= encCounter[j];
            }
            (key->counter)++;
            if((key->counter) == 0){
                
                pl_log_i( TAG,"  encryptBufferB counter overflow, generate new key requiered.\n"); 
                
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
        
        pl_log_d( TAG," macBuffer called.\n");
	if (verifyArguments("macBuffer", key, buffer, offset, *pLen, mac) == FAIL) {
	    return FAIL;
        }
/*
        if(key == NULL){
	    pl_log_e( TAG," macBuffer NULL key.\n");
	    return FAIL;	    
        }
        if(buffer == NULL){
	    pl_log_e( TAG," macBuffer NULL buffer.\n");
	    return FAIL;	    
        }
        if(offset > MAX_OFFSET){
	    pl_log_e( TAG," macBuffer offset is larger than max.\n");
	    return FAIL;	    
        }
        if(pLen == NULL || *pLen == 0){
	    pl_log_e( TAG," macBuffer NULL pLen or *pLen = 0.\n");
	    return FAIL;	    
        }
        if(mac == NULL){
	    pl_log_e( TAG," macBuffer NULL output mac.\n");
	    return FAIL;	    
        }
*/        
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
        uint8_t macLength = *pLen;
        error_t status = SUCCESS;        
        
        pl_printf("CryptoP:  verifyMac called.\n"); 
        
	if (verifyArgumentsShort("verifyMac", key, buffer, offset, *pLen) == FAIL) {
	    return FAIL;
        }
/*
        // Check sanity of the input parameters
         if(key == NULL){
	    pl_log_e( TAG," verifyMac NULL key.\n");
	    return FAIL;
        }
        if(buffer == NULL){
	    pl_log_e( TAG," verifyMac NULL buffer.\n");
	    return FAIL;
        }
        if(offset > MAX_OFFSET){
	    pl_log_e( TAG," verifyMac offset is larger than max.\n");
	    return FAIL;
        }
        if(pLen == NULL){
	    pl_log_e( TAG," verifyMac pLen NULL.\n");
	    return FAIL;
        }
*/
        if (*pLen < MAC_LENGTH){
            pl_log_e(TAG,"verifyMac input len smaller than mac length. %u\n", *pLen);
            return FAIL;
        }

        macLength = macLength - MAC_LENGTH;
        status = call CryptoRaw.macBuffer(key, buffer, offset, &macLength, mac); //calculate new mac	
	
        if((memcmp(mac, buffer + offset + *pLen - MAC_LENGTH, MAC_LENGTH)) != 0){ //compare new with received
            status = EWRONGMAC;            
            //pl_log_e( TAG,"  verifyMacFromNodeB message MAC does not match.\n"); 
            return status;
        }
        return status;
    }
    
    
    command error_t CryptoRaw.deriveKeyB(PL_key_t* masterKey, uint8_t* derivationData, uint8_t offset, uint8_t len, PL_key_t* derivedKey) {
        
         pl_log_d(TAG, " deriveKeyB called.\n"); 

        if(masterKey == NULL){
#ifndef SKIP_SELECTED_CRYPTO_RAW_MESSAGES
	    pl_log_e( TAG," deriveKeyB NULL masterKey.\n");
#endif
	    return FAIL;	    
        }
        if(offset > MAX_OFFSET){
#ifndef SKIP_SELECTED_CRYPTO_RAW_MESSAGES
	    pl_log_e( TAG," deriveKeyB offset is larger than max.\n");
#endif
	    return FAIL;	    
        }        
        if(len != BLOCK_SIZE){
#ifndef SKIP_SELECTED_CRYPTO_RAW_MESSAGES
	    pl_log_e( TAG," deriveKeyB len != BLOCK_SIZE.\n");
#endif
	    return FAIL;	    
        }       
        if(derivationData == NULL){
#ifndef SKIP_SELECTED_CRYPTO_RAW_MESSAGES
	    pl_log_e( TAG," deriveKeyB NULL derivationData.\n");
#endif
	    return FAIL;	    
        }        
        if(derivedKey == NULL){
#ifndef SKIP_SELECTED_CRYPTO_RAW_MESSAGES
	    pl_log_e( TAG," deriveKeyB NULL derivedKey.\n");
#endif
	    return FAIL;	    
        }
        
        call AES.keyExpansion( m_exp, (uint8_t*)(masterKey->keyValue));
        call AES.encrypt( derivationData + offset, m_exp, (uint8_t*)(derivedKey->keyValue));
        
        return SUCCESS;
    }
   
    command error_t CryptoRaw.hashDataBlockB( uint8_t* buffer, uint8_t offset, PL_key_t* key, uint8_t* hash){
        error_t status = SUCCESS;		
        uint8_t i;
        
        pl_log_d( TAG,"  hashDataBlockB called.\n");

	if (verifyArgumentsShort("hashDataBlockB", key, buffer, offset, 1) == FAIL) {
	    return FAIL;
        }
/*
        if(buffer == NULL){
	    pl_log_e( TAG," hashDataBlockB NULL buffer.\n");
	    return FAIL;	    
        }
        if(offset > MAX_OFFSET){
	    pl_log_e( TAG," hashDataBlockB offset is larger than max.\n");
	    return FAIL;	    
        }
        if(key == NULL){
	    pl_log_e( TAG," hashDataBlockB NULL key.\n");
	    return FAIL;	    
        }
*/
        if(hash == NULL){
	    pl_log_e( TAG," hashDataBlockB NULL hash.\n");
	    return FAIL;	    
        }
       
        //pl_log_d( TAG," keyValue = %2x%2x%2x%2x.\n", key->keyValue[0], key->keyValue[1], key->keyValue[2], key->keyValue[3]);
       
        call AES.keyExpansion( m_exp, (uint8_t*) key->keyValue);		
        call AES.encrypt(buffer + offset, m_exp, hash);
        for(i = 0; i < BLOCK_SIZE; i++){
            hash[i] = buffer[i + offset] ^ hash[i];
        }		
        return status;
    }
    
    
    command error_t CryptoRaw.protectBufferB( PL_key_t* key, uint8_t* buffer, uint8_t offset, uint8_t* pLen){
        error_t status = SUCCESS;

	if (verifyArgumentsShort("protectBufferB", key, buffer, offset, *pLen) == FAIL) {
	    return FAIL;
        }
	
/*
        if(key == NULL){
	    pl_log_e( TAG," protectBufferB NULL key.\n");
	    return FAIL;	    
        }
        if(buffer == NULL){
	    pl_log_e( TAG," protectBufferB NULL buffer.\n");
	    return FAIL;	    
        }
        if(offset > MAX_OFFSET){
	    pl_log_e( TAG," protectBufferB offset is larger than max.\n");
	    return FAIL;	    
        }
        if(pLen == NULL || *pLen == 0){
	    pl_log_e( TAG," protectBufferB NULL pLen || *pLen == 0.\n");
	    return FAIL;	    
        }
*/        
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
        pl_log_d( TAG, " unprotectBufferB called.\n");
        //offset is used for encryption shift, to verify SPheader, but not to encrypt it

        if((status = call CryptoRaw.decryptBufferB( key, buffer, offset, *pLen)) != SUCCESS){
            pl_log_e( TAG, "  unprotectBufferB encrypt failed.\n");
            return status;		
        }
        if((status = call CryptoRaw.verifyMac( key, buffer, 0, pLen)) != SUCCESS){            
            pl_log_e( TAG, "  unprotectBufferB mac verification failed, trying to sychronize counter.\n"); 
            for (i = 1; i <= COUNTER_SYNCHRONIZATION_WINDOW; i++){
		
		key->counter = counter - i;
		call CryptoRaw.decryptBufferB( key, buffer, offset, *pLen);
		if((status = call CryptoRaw.verifyMac( key, buffer, 0, pLen)) == SUCCESS){
		    pl_log_i( TAG, " counter synchronization succesfull.\n");
		    return status;
		}
		
                key->counter = counter + i;
		call CryptoRaw.decryptBufferB( key, buffer, offset, *pLen);
		if((status = call CryptoRaw.verifyMac( key, buffer, 0, pLen)) == SUCCESS){
		    pl_log_i( TAG, " counter synchronization succesfull.\n");
		    return status;
		}
            }
            pl_log_e(TAG, " counter could not be sychronized, decrypt failed.\n");
            key->counter = counter;
            return status;
        }
        return status;
    }
    
    command error_t CryptoRaw.selfTest(){
        uint8_t status = SUCCESS;
/*        
        uint8_t data[BLOCK_SIZE] = {0};
        uint8_t i;
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
*/
        return status;
    }
}

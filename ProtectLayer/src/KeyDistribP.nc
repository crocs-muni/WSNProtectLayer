/** 
 *  Component providing implementation of KeyDistrib interface.
 *  A module providing actual implementation of Key distribution component.
 * 	@version   0.1
 * 	@date      2012-2013
 */
#include "ProtectLayerGlobals.h"

module KeyDistribP{
    /*@{*/
    uses {
        interface Crypto; /**< Crypto interface is used */
        interface SharedData;
    }
    provides {
        interface Init as PLInit;
        interface KeyDistrib; /**< KeyDistrib interface is provided */
    }
    /*@}*/
}
implementation{
//TODO clean up and add parameters checks
   
    PL_key_t* m_testKey;	/**< handle to key for selfTest */
    Signature_t signature;
    static const char *TAG = "CryptoRawP";

    //
    //	Init interface
    //
    command error_t PLInit.init() {
    
        pl_printf("KeyDistribP: <KeyDistribP.PLInit.init()>\n"); 
        call KeyDistrib.discoverKeys();
        pl_printf("KeyDistribP: </KeyDistribP.PLInit.init()>\n"); 
        
        
        
        pl_printfflush();
        return SUCCESS;
    }
    
    command void KeyDistrib.compute(){   
        uint8_t i;
	call Crypto.computeSignature(0, 10, &signature);
	    pl_printf("Level 0 computed signature:\n");
	    for(i = 0; i < SIGNATURE_LENGTH; i++){
		pl_printf("0x%02x ", signature.signature[i]);
	}
        pl_printf("\n");
        /*
        pl_printfflush();
        call Crypto.computeSignature(1, 10, &signature);
	    pl_printf("Level 1 computed signature:\n");
	    for(i = 0; i < SIGNATURE_LENGTH; i++){
		pl_printf("0x%02x ", signature.signature[i]);
	}
        pl_printf("\n");
        pl_printfflush();
        call Crypto.computeSignature(2, 10, &signature);
	    pl_printf("Level 2 computed signature:\n");
	    for(i = 0; i < SIGNATURE_LENGTH; i++){
		pl_printf("0x%02x ", signature.signature[i]);
	}
        pl_printf("\n");
        pl_printfflush();
        call Crypto.computeSignature(3, 10, &signature);
	    pl_printf("Level 3 computed signature:\n");
	    for(i = 0; i < SIGNATURE_LENGTH; i++){
		pl_printf("0x%02x ", signature.signature[i]);
	}
        pl_printf("\n");
        pl_printfflush();
        */
    }

    //
    //	KeyDistrib interface
    //
    command error_t KeyDistrib.discoverKeys() {
        error_t status = SUCCESS;

        pl_printf("KeyDistribP: <KeyDistrib.discoverKeys>.\n");
        if((status = call Crypto.initCryptoIIB()) != SUCCESS){
            pl_printf("KeyDistribP: KeyDistrib.discoverKeys failed.\n"); 
            return status;
        }
        pl_printf("KeyDistribP: </KeyDistrib.discoverKeys>.\n"); 
        return status;
    }

    command error_t KeyDistrib.getKeyToNodeB(uint8_t nodeID, PL_key_t* pNodeKey){
        SavedData_t* pSavedData = NULL;
        pl_printf("KeyDistribP: KeyDistrib.getKeyToNodeB called for node '%u'\n", nodeID); 

        if(nodeID > NODE_MAX_ID || nodeID <= 0){
	    pl_log_e(TAG,"KeyDistribP: invalid node ID.\n");
	    return FAIL;
        }
        if(pNodeKey == NULL){
	    pl_log_e(TAG,"KeyDistribP: pNodeKey NULL.\n");
	    return FAIL;
        }

        pSavedData = call SharedData.getNodeState(nodeID);
        if (pSavedData != NULL) {
            pNodeKey =  &((pSavedData->kdcData).shared_key);
            return SUCCESS;
        }
        else {
            pl_printf("KeyDistribP: Failed to obtain SharedData.getNodeState.\n"); 
            return EKEYNOTFOUND;
        }
    }

    command error_t KeyDistrib.getKeyToBSB(PL_key_t* pBSKey) {
        KDCPrivData_t* KDCPrivData = NULL;

        if(pBSKey == NULL){
	    pl_log_e(TAG,"KeyDistribP: pBSKey NULL.\n");
	    return FAIL;
        }

        pl_printf("KeyDistribP: getKeyToBSB called.\n"); 
        KDCPrivData = call SharedData.getKDCPrivData();
        if(KDCPrivData == NULL){
            pl_printf("KeyDistribP: getKeyToBSB key not received\n"); 
            return EKEYNOTFOUND;
        } else {		
            pBSKey = &(KDCPrivData->keyToBS);
            return SUCCESS;
        }
    }

    command error_t KeyDistrib.getHashKeyB(PL_key_t** pHashKey) {
        KDCPrivData_t* KDCPrivData = NULL;

        pl_printf("KeyDistribP: getHashKeyB called.\n");
        KDCPrivData = call SharedData.getKDCPrivData();
        if(KDCPrivData == NULL){
            pl_printf("KeyDistribP: getHashKeyB key not received\n");
            return EKEYNOTFOUND;
        } else {		
            *pHashKey = &(KDCPrivData->hashKey);
            return SUCCESS;
        }
    }

    command error_t KeyDistrib.selfTest(){
        uint8_t status = SUCCESS;

        pl_printf("KeyDistribP:  Self test initiated.\n"); 
        m_testKey = NULL;
        pl_printf("KeyDistribP:  Self test getKeyToBS.\n"); 
        if((status = call KeyDistrib.getKeyToBSB(m_testKey)) != SUCCESS){
            pl_printf("KeyDistribP:  Self test getKeyToBS failed.\n"); 
            return status;
        }
        pl_printf("KeyDistribP:  Self test getKeyToNodeB with ID 0.\n"); 
        if((status = call KeyDistrib.getKeyToNodeB( 0, m_testKey)) != SUCCESS){
            pl_printf("KeyDistribP:  Self test getKeyToNodeB failed.\n"); 
            return status;
        }
        pl_printf("KeyDistribP: Self test finished.\n"); 
        return status;
    }
}

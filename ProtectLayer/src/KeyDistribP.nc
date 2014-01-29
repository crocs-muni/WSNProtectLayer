/** 
 *  Component providing implementation of KeyDistrib interface.
 *  A module providing actual implementation of Key distribution component.
 * 	@version   0.1
 * 	@date      2012-2013
 */
#include "ProtectLayerGlobals.h"
#include "printf.h"

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
    //uint8_t m_currentNodeIndex; /**< index of current node processed pointing to m_neighborsID - used in recurrent tasks to identify index of node next to be processed */
    //uint8_t m_lastNodeIndex;    /**< index of last value set in m_neighborsID */
    //uint8_t m_neighborsID[MAX_NEIGHBOR_COUNT]; /**< array of neighbors IDs - use for lookup into shared data structures */
    //uint16_t m_state;			/**< current state of the component - used to decice on next step inside task */
    //uint8_t  m_getKeyToNodeID;  /**< ID of node fro which getKeyToNode command was issued */
    //PL_key_t m_keysToNodes[MAX_NEIGHBOR_COUNT]; /**< handles to keys shared with separate neighbors */
    
    //blocking version of key derivation
#define BLOCKING 
    
    PL_key_t* m_testKey;			/**< handle to key for selfTest */
    
    //
    //	Init interface
    //
    /**
            Command: Perform initialization of KeyDistribP component (should be called only once after reset)
            @todo if internal state was already established (only reset occured), initializtion should load values from shared memory
            @return error_t status. SUCCESS only
    */
    command error_t PLInit.init() {
        //uint8_t i = 0;
        
        printf("KeyDistribP: KeyDistribP.PLInit.init() entered\n"); printfflush();
        
        
        // TODO: do other initialization
        //m_state = 0;
        
        call KeyDistrib.discoverKeys();
        
        // m_keyToBS initialization
        //m_keyToBS.keyType = KEY_TOBS;
        //for (i = 0; i < KEY_LENGTH; i++) m_keyToBS.keyValue[i] = 0;
        
        printf("KeyDistribP: KeyDistribP.PLInit.init() finished\n"); printfflush();
        
        
        return SUCCESS;
    }		
    
    
    //
    //	KeyDistrib interface
    //
    
    
    
    
    
    /**
        Command: depending on define of BLOCKING either posts task for 
        key task_discoverKeys for key discovery or initialization of Crypto II.		
        @return error_t status. 
    */	
    command error_t KeyDistrib.discoverKeys() {
        error_t status = SUCCESS;
        
        printf("KeyDistribP: KeyDistrib.discoverKeys called.\n"); printfflush();
        
        //#ifdef BLOCKING
        if((status = call Crypto.initCryptoIIB()) != SUCCESS){
            
            printf("KeyDistribP: KeyDistrib.discoverKeys failed.\n"); printfflush();
            
            return status;
        }
        
        printf("KeyDistribP: KeyDistrib.discoverKeys finished.\n"); printfflush();
        
        return status;
        
        //#else /* use non blocking variant */
        /*
        if (m_state & FLAG_STATE_KDP_DISCOVERKEYS) {
            return EALREADY;	
        }
        else {
            // Change state to discovery and post task to process first node
            m_state |= FLAG_STATE_KDP_DISCOVERKEYS;
            m_currentNodeIndex = 0;
            post task_discoverKeys();
            return SUCCESS;
        }
        */
        //#endif /* Blocking */
        
    }
    
    
    
    //changed header to unify interface with getKeyToBS, thus changed functionality 
    command error_t KeyDistrib.getKeyToNodeB(uint8_t nodeID, PL_key_t* pNodeKey){
        //uint16_t temp = nodeID;
        SavedData_t* pSavedData = NULL;
        
        //printf("This is node with ID %u \n", TOS_NODE_ID); printfflush();
        printf("KeyDistribP: KeyDistrib.getKeyToNodeB called for node '%u'\n", nodeID); printfflush();
        
        pSavedData = call SharedData.getNodeState(nodeID);
        if (pSavedData != NULL) {
            //printf("KeyDistribP: Shared key retrieved.\n"); printfflush();
            
            pNodeKey =  &((pSavedData->kdcData).shared_key);
            
            return SUCCESS;
        }
        else {
            
            printf("KeyDistribP: Failed to obtain SharedData.getNodeState.\n"); printfflush();
            
            return EKEYNOTFOUND;
        }
    }
    
    command error_t KeyDistrib.getKeyToBSB(PL_key_t* pBSKey) {
        KDCPrivData_t* KDCPrivData = NULL;
        
        printf("KeyDistribP: getKeyToBSB called.\n"); printfflush();
        
        KDCPrivData = call SharedData.getKDCPrivData();
        if(KDCPrivData == NULL){
            
            printf("KeyDistribP: getKeyToBSB key not received\n"); printfflush();
            
            return EKEYNOTFOUND;
        } else {		
            pBSKey = &(KDCPrivData->keyToBS);
            return SUCCESS;
        }
    }	
    
    command error_t KeyDistrib.selfTest(){
        uint8_t status = SUCCESS;
        
        printf("KeyDistribP:  Self test initiated.\n"); printfflush();
        
        m_testKey = NULL;
        printf("KeyDistribP:  Self test getKeyToBS.\n"); printfflush();
        
        if((status = call KeyDistrib.getKeyToBSB(m_testKey)) != SUCCESS){
            printf("KeyDistribP:  Self test getKeyToBS failed.\n"); printfflush();
            
            return status;
        }
        printf("KeyDistribP:  Self test getKeyToNodeB with ID 0.\n"); printfflush();
        
        if((status = call KeyDistrib.getKeyToNodeB( 0, m_testKey)) != SUCCESS){
            printf("KeyDistribP:  Self test getKeyToNodeB failed.\n"); printfflush();
            
            return status;
        }
        printf("KeyDistribP: Self test finished.\n"); printfflush();
        
        return status;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
*	DEPRICATED
*
*/	
    
    /**
        Event: Default handler for KeyDistrib.discoverKeysDone event
        @param error_t status returned by task_discoverKeys task
        @return nothing
    */	
    //default event void KeyDistrib.discoverKeysDone(error_t result) {}
    /*
    */
    /**
        Task: Performs key discovery among direct neighbours. This task repost itself until last node is processed
        Signal: KeyDistrib.discoverKeysDone
        @return nothing
    */
    /*
    task void task_discoverKeys() {
            error_t status = SUCCESS;
            error_t tmpStatus = SUCCESS;
            SavedData_t*    pSavedData = NULL;
            KDCPrivData_t*  kdcPrivData = NULL;
            uint8_t i;
            
            printf("KeyDistribP: KeyDistrib.task_discoverKeys called.\n"); printfflush();
            
            
            // BUGBUG: simulation of key discovery: key value is formed as X|Y where X and Y are nodeIDs of two neighbours.
            // First part (X) is lower ID, Y is higher ID (so that task_discoverKeys on pair node will result in same key value)
            pSavedData = call SharedData.getSavedData();
            for (i = 0; i < MAX_NEIGHBOR_COUNT; i++) {
                if (pSavedData[i].nodeId > 0) {
                    //TODO: we should call Crypto.generateKey(&(pSavedData[i].kdcData.shared_key)); and wait for generation of new key
                    
                    
                    //TODO: new: do not save generated key to kdcData, use generate key from crypto.
                    //		 here just discover neighbours, fill their IDs to SavedData structure and call crypto init II to 
                    //		 process key generation
                    if ((tmpStatus = call Crypto.deriveKeyB(&(pSavedData[i].kdcData.shared_key))) == SUCCESS) {
                        pSavedData[i].kdcData.shared_key.keyType = KEY_TONODE;
                        pSavedData[i].kdcData.shared_key.keyValue[0] = (pSavedData[i].nodeId < TOS_NODE_ID) ? pSavedData[i].nodeId : TOS_NODE_ID;
                        pSavedData[i].kdcData.shared_key.keyValue[1] = (pSavedData[i].nodeId < TOS_NODE_ID) ? TOS_NODE_ID : pSavedData[i].nodeId;
                    }
                    else {
                        printf("KeyDistribP: KeyDistrib.task_discoverKeys failed to generate new key for node '%d' .\n", pSavedData[i].nodeId); printfflush();
                        
                        status = ENOTALLKEYSDISCOVERED;
                    }
                }
            }
            
            // Create key to BS
            kdcPrivData = call SharedData.getKDCPrivData();
            if ((tmpStatus = call Crypto.deriveKeyB(&(kdcPrivData->keyToBS))) == SUCCESS) {
                kdcPrivData->keyToBS.keyType = KEY_TOBS;
                kdcPrivData->keyToBS.keyValue[0] = TOS_NODE_ID;
                kdcPrivData->keyToBS.keyValue[1] = 0xff;
            }
            else {
                printf("KeyDistribP: KeyDistrib.task_discoverKeys failed to generate new key for BS.\n"); printfflush();
                
                status = ENOTALLKEYSDISCOVERED;
            }
            
            
            signal KeyDistrib.discoverKeysDone(status);
            
 THIS IS BETTER VERSION WITH SEPARATE TASK FOR EVERY NODE
                    printf("KeyDistribP: KeyDistrib.task_discoverKeys for node '%d' called.\n", m_currentNodeIndex); printfflush();
                    
                // TODO: initiate discovery
        // We will have multiple nodes, make task for every separate node
        // for_each neigh_node post task process
                if (m_currentNodeIndex < MAX_NEIGHBOR_COUNT) {
                    // TODO: process current node
                    
                    // repost task to process next node
                    m_currentNodeIndex++;
                    post task_discoverKeys();
        }
                if (m_currentNodeIndex == MAX_NEIGHBOR_COUNT) {
                    // we are done
                    m_state &= ~FLAG_STATE_KDP_DISCOVERKEYS;
                    // TODO: remember status results from all keys
                    signal KeyDistrib.discoverKeysDone(SUCCESS);
                }
                
        }
    */
    
    
    /**
        Task: Returns handle to key shared between node and base station
        Signal: KeyDistrib.getKeyToBSDone
        @return nothing
    */
    /*
    task void task_getKeyToBS() {
                printf("KeyDistribP: KeyDistrib.task_getKeyToBS called.\n"); printfflush();
                
        m_state &= ~FLAG_STATE_KDP_GETKEYTOBS;
        signal KeyDistrib.getKeyToBSDone(SUCCESS, &m_keyToBS);
    }
    */
    /**
        Command: Posts taks task_getKeyToBS for obtaining key to base station
        @return error_t status. SUCCESS or EALREADY if already pending
    */
    /*
    command error_t KeyDistrib.getKeyToBS() {
                printf("KeyDistribP: KeyDistrib.getKeyToBS called.\n"); printfflush();
                
        if (m_state & FLAG_STATE_KDP_GETKEYTOBS) {
            return EALREADY;	
        }
        else {
            m_state |= FLAG_STATE_KDP_GETKEYTOBS;
            post task_getKeyToBS();
            return SUCCESS;
        }
    }
    */
    /**
        Event: Default handler for KeyDistrib.getKeyToBSDone event
        @param resultreturned by task_getKeyToBS
        @param pBSKey handle to key shared between node and base station
        @return nothing
    */	
    //default event void KeyDistrib.getKeyToBSDone(error_t result, PL_key_t* pBSKey) {}
    
    /**
        Task: Returns handle to key shared between this node and other node specified by nodeID
        Signal: KeyDistrib.getKeyToNodeDone
        @return nothing
    */
    /*
    task void task_getKeyToNode() {
        // todo: call getKeyToNodeB
            SavedData_t* pSavedData = NULL;
            printf("KeyDistribP: KeyDistrib.task_getKeyToNode called.\n"); printfflush();
            
            m_state &= ~FLAG_STATE_KDP_GETKEYTONODE;
            pSavedData = call SharedData.getNodeState(m_getKeyToNodeID);
            
            if (pSavedData != NULL) {
                signal KeyDistrib.getKeyToNodeDone(SUCCESS, &(pSavedData->kdcData.shared_key));
            }
            else {
                 printf("KeyDistribP: Failed to obtain SharedData.getNodeState.\n"); printfflush();
                 
                signal KeyDistrib.getKeyToNodeDone(EKEYNOTFOUND, NULL);
            }
        }
*/
    /**
        Command: Posts task task_getKeyToNode for obtaining handle to key shared between this node and other node specified by nodeID
        @return error_t status. SUCCESS or EALREADY if already pending
    */
    /*
    command error_t KeyDistrib.getKeyToNode(uint8_t nodeID) {
                printf("KeyDistribP: KeyDistrib.getKeyToNode(%d) called.\n", nodeID); printfflush();
                
        if (m_state & FLAG_STATE_KDP_GETKEYTONODE) {
            return EALREADY;	
        }
        else {
            m_getKeyToNodeID = nodeID;
            m_state |= FLAG_STATE_KDP_GETKEYTONODE;
            post task_getKeyToNode();
            return SUCCESS;
        }
    }
    */
    /**
        Event: Default handler for KeyDistrib.getKeyToNodeDone event
        @param result returned by task_getKeyToNode
        @param pNodeKey handle to key shared between this node and specified node
        @return nothing
    */	
    //default event void KeyDistrib.getKeyToNodeDone(error_t result, PL_key_t* pNodeKey) {}
    
    
    
    
    
    //
    // Crypto interface
    //		
    /**
        Event handler for Crypto.encryptBufferDone event
    */	
    //event void Crypto.encryptBufferDone(error_t status, uint8_t* buffer, uint8_t resultLen) {}
    /**
        Event handler for Crypto.decryptBufferDone event
    */	
    //event void Crypto.decryptBufferDone(error_t status, uint8_t* buffer, uint8_t resultLen) {}
    /**
        Event handler for Crypto.deriveKeyDone event
    */	
    //event void Crypto.deriveKeyDone(error_t status, PL_key_t* derivedKey) {}
    /**
        Event handler for Crypto.generateKeyDone event
    */	
    //event void Crypto.generateKeyDone(error_t status, PL_key_t* newKey) {}
    
    
    
    
}

/**
 * Core implementation of SharedData module. Offers the easy access methods from
 * the SharedData interface and implements the data backup and restore from 
 * flash memory.
 * 
 * @author Filip Jurnecka
 */

#include "ProtectLayerGlobals.h"
module SharedDataP {
    provides {
        interface SharedData;
#ifndef TOSSIM
        interface ResourceArbiter;
#endif
        interface Init as PLInit;
    }
#ifndef TOSSIM
    uses {
        interface BlockRead as FlashDataRead;
        interface BlockWrite as FlashDataWrite;
    }
#endif
}

implementation {
    // Logging tag for this component
    static const char *TAG = "SharedP";
    
    /** storage variable with the entire combinedData structure */
    combinedData_t combinedData;
    
	/** pointer to the currently processed key */
	nx_uint8_t * currentKey;

    /** flag signaling whether the memory is currently busy */
    bool m_busy = FALSE;
    bool initialized = FALSE;

	/** flag signaling operations regarding combined data storage */
	bool combDataFlag = FALSE;
	
	/** indicator of current position in memory */
	storage_addr_t memPosition = 0;

    /** 
     * Initialize the combinedData structure to initial zeros
     */
    
    command error_t PLInit.init() {
        int i = 0;
        int j = 0;
        uint8_t fixedNeighbors[MAX_NEIGHBOR_COUNT] = {4,5,6,7,10,14,15,17,19,22,25,28,29,30,31,32,33,35,36,37,40,41,42,43,44,46,47,48,50};
        
        // 
        //	Create virtual pre-distributed keys
        //
        // Keys to all other nodes
        for (i = 0; i < MAX_NEIGHBOR_COUNT; i++) {
            combinedData.kdcPrivData.preKeys[i].keyType = KEY_TONODE;
            for (j = 0; j < KEY_LENGTH; j++) combinedData.kdcPrivData.preKeys[i].keyValue[j] = TOS_NODE_ID ^ fixedNeighbors[i] ^ j; // construct unique key value, but deterministic
            combinedData.kdcPrivData.preKeys[i].dbgKeyID = 0;
            combinedData.kdcPrivData.preKeys[i].counter = 0;
        }
        // Create key to BS
        combinedData.kdcPrivData.keyToBS.keyType = KEY_TOBS;
        memset(combinedData.kdcPrivData.keyToBS.keyValue, 0, KEY_LENGTH);
        combinedData.kdcPrivData.keyToBS.dbgKeyID = 0;
        combinedData.kdcPrivData.keyToBS.counter  = 0;
        
        //
        //  Init routing table to BS for current node
        //	TODO: fixed routing table at the moment, will be replaced by CTP	
        //		
        combinedData.routePrivData.isValid = 1;
        switch (TOS_NODE_ID) {
        case 4: { combinedData.routePrivData.parentNodeId = 41; break; }
        case 5: { combinedData.routePrivData.parentNodeId = 40; break; }
        case 6: { combinedData.routePrivData.parentNodeId = 19; break; }
        case 7: { combinedData.routePrivData.parentNodeId = 17; break; }
        case 10: { combinedData.routePrivData.parentNodeId = 25; break; }
        case 14: { combinedData.routePrivData.parentNodeId = 37; break; }
        case 15: { combinedData.routePrivData.parentNodeId = 17; break; }
        case 17: { combinedData.routePrivData.parentNodeId = 37; break; }
        case 19: { combinedData.routePrivData.parentNodeId = 4; break; }
        case 22: { combinedData.routePrivData.parentNodeId = 41; break; }
        case 25: { combinedData.routePrivData.parentNodeId = 44; break; }
        case 28: { combinedData.routePrivData.parentNodeId = 4; break; }
        case 29: { combinedData.routePrivData.parentNodeId = 50; break; }
        case 30: { combinedData.routePrivData.parentNodeId = 35; break; }
        case 31: { combinedData.routePrivData.parentNodeId = 41; break; }
        case 32: { combinedData.routePrivData.parentNodeId = 50; break; }
        case 33: { combinedData.routePrivData.parentNodeId = 41; break; }
        case 35: { combinedData.routePrivData.parentNodeId = 22; break; }
        case 36: { combinedData.routePrivData.parentNodeId = 42; break; }
        case 37: { combinedData.routePrivData.parentNodeId = 41; break; }
        case 40: { combinedData.routePrivData.parentNodeId = 41; break; }
        case 41: { combinedData.routePrivData.parentNodeId = 41; break; }
        case 42: { combinedData.routePrivData.parentNodeId = 22; break; }
        case 43: { combinedData.routePrivData.parentNodeId = 14; break; }
        case 44: { combinedData.routePrivData.parentNodeId = 41; break; }
        case 46: { combinedData.routePrivData.parentNodeId = 33; break; }
        case 47: { combinedData.routePrivData.parentNodeId = 46; break; }
        case 48: { combinedData.routePrivData.parentNodeId = 33; break; }
        case 50: { combinedData.routePrivData.parentNodeId = 31; break; }
        default: combinedData.routePrivData.isValid = 0;
        } 
        
        //
        // Privacy component
        //
        combinedData.ppcPrivData.priv_level = 0;
        
        //
        // Set default values to list of all neighbours		
        for (i = 0; i < MAX_NEIGHBOR_COUNT; i++) {
            combinedData.savedData[i].nodeId = INVALID_NODE_ID;
            memset(&(combinedData.savedData[i].kdcData), 0, sizeof(combinedData.savedData[i].kdcData));
            memset(&(combinedData.savedData[i].idsData), 0, sizeof(combinedData.savedData[i].idsData));
        }
		
	// TODO: substitute in final version by CTP
        for (i = 0; i < MAX_FIXED_NEIGHBOR_COUNT; i++) {
	    pl_log_d(TAG, "neigh %d.\n", fixedNeighborsMap[TOS_NODE_ID][i]);
            if (fixedNeighborsMap[TOS_NODE_ID][i] != 0) combinedData.savedData[i].nodeId = fixedNeighborsMap[TOS_NODE_ID][i];
        }	

        pl_log_i(TAG, "PLInit.init() finished.\n");

        initialized = TRUE;
        return SUCCESS;
    }
    
    /**
     * Easy access method to the entire structure of combinedData
     * 
     * @return a pointer to the combinedData structure
     */
    command combinedData_t * SharedData.getAllData(){
        if(initialized){
            pl_log_d(TAG, "getAllData called on initialized data.\n");
        } else {
            pl_log_e(TAG, "ERROR, data not initialized.\n");
        }	
        return &combinedData;
    }
    
    /**
     * A shortcut method to the savedData structure
     * 
     * @return a pointer to the entire savedData of the combinedData structure
     */
    command SavedData_t * SharedData.getSavedData(){
        if(initialized){
            pl_log_d(TAG, "getSavedData called on initialized data.\n");
        } else {
            pl_log_e(TAG, "ERROR, data not initialized.\n");
        }
        return combinedData.savedData;
    }
    
    /**
     * A shortcut to savedData of a particular neighbor.
     * 
     * @param nodeId the id of requested neighboring node
     * @return a pointer to the savedData of identified neighbor or NULL if such a neighbor is not stored
     */
    command SavedData_t * SharedData.getNodeState(uint16_t nodeId){
        int i;
        
        if(initialized){
            pl_log_d(TAG, "getNodeState called on initialized data for node %u.\n", nodeId);
        } else {
            pl_log_d(TAG, "getAllData called for node %u.\n", nodeId); 
            pl_log_e(TAG, "ERROR, data not initialized.\n");
        }
        
        for (i = 0; i < MAX_NEIGHBOR_COUNT; i++) {
            if (combinedData.savedData[i].nodeId == nodeId)
                return &(combinedData.savedData[i]);
        }				
        return NULL;
    }
    
    /**
     * A shortcut to the privacy module's private data.
     * 
     * @return a pointer to the privacy module's private data from the combinedData structure
     */
    command PPCPrivData_t* SharedData.getPPCPrivData() {
        if(initialized){
            pl_log_d(TAG, "getPPCPrivData called on initialized data.\n"); 
        } else {
            pl_log_d(TAG, "getPPCPrivData called.\n"); 
            pl_log_e(TAG, "ERROR, data not initialized.\n"); 
        }
        return &(combinedData.ppcPrivData);		
    }
    
    /**
     * A shortcut to the routing module's private data.
     * 
     * @return a pointer to the routing module's private data from the combinedData structure
     */
    command RoutePrivData_t* SharedData.getRPrivData() {
        if(initialized){
            pl_log_d(TAG, "getRPrivData called on initialized data.\n");
        } else {
            pl_log_d(TAG, "getRPrivData called.\n");
            pl_log_e(TAG, "ERROR, data not initialized.\n");
        }
        return &(combinedData.routePrivData);		
    }
    
    /**
     * A shortcut to the key distribution module's private data.
     * 
     * @return a pointer to the privacy module's private data from the combinedData structure
     */
    command KDCPrivData_t* SharedData.getKDCPrivData() {
        if(initialized){
            pl_log_d(TAG, "getKDCPrivData called on initialized data.\n"); 
        } else {
            pl_log_d(TAG, "getKDCPrivData called.\n"); 
            pl_log_e(TAG, "ERROR, data not initialized.\n"); 
        }
        return &(combinedData.kdcPrivData);		
    }	
    
    /**
      * A shortcut to the predistributed keys.
      * @param nodeId id of node
      * @return a handle to predistributed key for node.
      */
    command PL_key_t* SharedData.getPredistributedKeyForNode(uint16_t nodeId){
        KDCPrivData_t* KDCPrivData = call SharedData.getKDCPrivData();
        return &(KDCPrivData->preKeys[nodeId]);
    }
    
#ifndef TOSSIM
    /**
     * A command to backup the entire combinedData structure to the flash memory
     * 
     * @return 
     * <li>SUCCESS if the request was accepted, 
     * <li>EBUSY if a request is already being processed.
     */
    command error_t ResourceArbiter.saveCombinedDataToFlash(){
        pl_log_d(TAG, "saveCombinedDataToFlash called.\n"); 

        if (!m_busy) {
			m_busy = TRUE;
			combDataFlag = TRUE;
			return call FlashDataWrite.erase();			
		}
		return EBUSY;
    }
    
    default event void ResourceArbiter.saveCombinedDataToFlashDone(error_t result) {
    	pl_log_d(TAG, "saveCombinedDataToFlashDone.\n"); 

}
    
    /**
     * Signals the completion of a write operation. However, data is not
     * guaranteed to survive a power-cycle unless a sync operation has
     * been completed.
     *
     * @param addr starting address of write.
     * @param 'void* COUNT(len) buf' buffer that written data was read from.
     * @param len number of bytes written.
     * @param error SUCCESS if the operation was successful, FAIL if
     *   it failed
     */
    event void FlashDataWrite.writeDone(storage_addr_t addr, void *buf, storage_len_t len, error_t err) {
    	m_busy = FALSE;
    	if (combDataFlag) {
	    	signal ResourceArbiter.saveCombinedDataToFlashDone(err);
	    } else {
	    	memPosition += len;
			signal ResourceArbiter.saveKeyToFlashDone(err);
		}
    	combDataFlag = FALSE;
	}
    
    /**
     * A command to restore the saved combinedData structure form the flash memory
     * and rewrite the current data in combinedData.
     * 
     * @return 
     *   <li>SUCCESS if the request was accepted, 
     *   <li>EINVAL if the parameters are invalid
     *   <li>EBUSY if a request is already being processed.
     */
    command error_t ResourceArbiter.restoreCombinedDataFromFlash(){
    if (!m_busy) {
			m_busy = TRUE;
			combDataFlag = TRUE;
			return call FlashDataRead.read(0, &combinedData, sizeof(combinedData_t));
		}
		return EBUSY;
	}
    
    default event void ResourceArbiter.restoreCombinedDataFromFlashDone(error_t result) {}

command error_t ResourceArbiter.saveKeyToFlash(nx_uint8_t * key) {
		if (!m_busy) {
			m_busy = TRUE;
			if (memPosition == 0) {
				currentKey = key;
				return call FlashDataWrite.erase();
			} else {
				return call FlashDataWrite.write(memPosition, key, KEY_LENGTH);
			}
		}
		return EBUSY;
	}
	
	default event void ResourceArbiter.saveKeyToFlashDone(error_t result) {}

	command error_t ResourceArbiter.restoreKeyFromFlash(uint8_t neighbourId){
		if (!m_busy) {
			m_busy = TRUE;
			return call FlashDataRead.read((neighbourId - 1) * KEY_LENGTH, currentKey, KEY_LENGTH);
		}
		return EBUSY;
	}
	
	default event void ResourceArbiter.restoreKeyFromFlashDone(error_t result) {}
	
    
    /**
     * Signals the completion of a read operation.
     *
     * @param addr starting address of read.
     * @param 'void* COUNT(len) buf' buffer where read data was placed.
     * @param len number of bytes read.
     * @param error SUCCESS if the operation was successful, FAIL if
     *   it failed
     */
    event void FlashDataRead.readDone(storage_addr_t addr, void *buf, storage_len_t len, error_t err) {
    	m_busy = FALSE;
    	if (combDataFlag) {
	    	signal ResourceArbiter.restoreCombinedDataFromFlashDone(err);
	    } else {
	    	signal ResourceArbiter.restoreKeyFromFlashDone(err);
	    }
	    combDataFlag = FALSE;
	}
    
    /**
     * Signals the completion of a crc computation.
     *
     * @param addr stating address.
     * @param len number of bytes the crc was computed over.
     * @param crc the resulting crc value.
     * @param error SUCCESS if the operation was successful, FAIL if
     *   it failed
     */
    event void FlashDataRead.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error){
}
    
    /**
     * Signals the completion of a sync operation. All written data is
     * flushed to non-volatile storage after this event.
     *
     * @param error SUCCESS if the operation was successful, FAIL if
     *   it failed
     */
    event void FlashDataWrite.syncDone(error_t error){
}
    
/**
   	 * Signals the completion of an erase operation.
   	 *
   	 * @param error SUCCESS if the operation was successful, FAIL if
   	 *   it failed
   	 */
	event void FlashDataWrite.eraseDone(error_t error){
		if (error == SUCCESS) {
			if (combDataFlag) {
				//TODO possible extension in order not to overwrite combinedData by keys and vice versa
				//either create a separate memory block in the *.xml config or share the memPosition? 
				call FlashDataWrite.write(0, &combinedData, sizeof(combinedData_t));
			} else {
				call FlashDataWrite.write(memPosition, currentKey, KEY_LENGTH);
			}
		} else {
			combDataFlag = FALSE;
		}
	}

	#endif

	command nx_uint8_t * ResourceArbiter.getCurrentKey() {
		return currentKey;
	}
	
	command uint32_t ResourceArbiter.getNumberOfStoredKeys() {
		//pl_printf("number of stored keys: %d", (memPosition / KEY_LENGTH));
		return memPosition / KEY_LENGTH; 
	}
}
    

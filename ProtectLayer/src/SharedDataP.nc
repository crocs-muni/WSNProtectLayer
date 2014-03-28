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
	//uint8_t * currentKey;

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
        call ResourceArbiter.restoreCombinedDataFromFlash();
        if (combinedData.magicWord != MAGIC_WORD) {
        	memset(&combinedData, 0, sizeof(combinedData));
        	combinedData.magicWord = MAGIC_WORD;
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
            pl_log_e(TAG, "ERROR, getNodeState called but data not initialized yet.\n");
        }
        
        for (i = 0; i < MAX_NEIGHBOR_COUNT; i++) {
            if (combinedData.savedData[i].nodeId == nodeId)
                return &(combinedData.savedData[i]);
        }				
        pl_log_d(TAG, "NodeState for node %u not found (not neighbor)\n", nodeId);
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
    command error_t SharedData.getPredistributedKeyForNode(uint16_t nodeId, PL_key_t* predistribKey){
        return call ResourceArbiter.restoreKeyFromFlash(nodeId, predistribKey);

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

	command error_t ResourceArbiter.restoreKeyFromFlash(uint16_t neighbourId, PL_key_t* predistribKey){
		if (!m_busy) {
			m_busy = TRUE;
			return call FlashDataRead.read((neighbourId - 1) * KEY_LENGTH, predistribKey, KEY_LENGTH);
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
    

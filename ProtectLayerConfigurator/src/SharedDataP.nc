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
		interface Init;
	}
	#ifndef TOSSIM
	uses {
		interface BlockRead as KeysDataRead;
		interface BlockWrite as KeysDataWrite;
		interface BlockRead as SharedDataRead;
		interface BlockWrite as SharedDataWrite;
	}
		#endif
}

implementation {
	/** storage variable with the entire combinedData structure */
	combinedData_t combinedData;
	
	/** pointer to the currently processed key */
	nx_uint8_t * currentKey;
	
	/** flag signaling whether the memory is currently busy */
	bool m_busy = FALSE;
	
	/** flag signaling operations regarding combined data storage */
	//bool combDataFlag = FALSE;
	
	/** indicator of current position in memory */
	storage_addr_t memPosition = 0;
	
	/** 
	 * Initialize the combinedData structure to initial zeros
	 */
	command error_t Init.init() {
		memset(&combinedData, 0, sizeof(combinedData));
		combinedData.magicWord = MAGIC_WORD;
		
		if (!m_busy) {
			m_busy = TRUE;
			return call ResourceArbiter.saveCombinedDataToFlash();
		}
        return FAIL;
	}

	/**
	 * Easy access method to the entire structure of combinedData
	 * 
	 * @return a pointer to the combinedData structure
	 */
	command combinedData_t * SharedData.getAllData(){
		return &combinedData;
	}
	
	/**
	 * A shortcut method to the savedData structure
	 * 
	 * @return a pointer to the entire savedData of the combinedData structure
	 */
	command SavedData_t * SharedData.getSavedData(){
		return combinedData.savedData;
	}
	
	/**
	 * A shortcut to savedData of a particular neighbor.
	 * 
	 * @param nodeId the id of requested neighboring node
	 * @return a pointer to the savedData of identified neighbor or NULL if such a neighbor is not stored
	 */
	command SavedData_t * SharedData.getNodeState(uint8_t nodeId){
		int i;
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
		return &(combinedData.ppcPrivData);		
	}
	
	/**
	 * A shortcut to the routing module's private data.
	 * 
	 * @return a pointer to the routing module's private data from the combinedData structure
	 */
	command RoutePrivData_t* SharedData.getRPrivData() {
		return &(combinedData.routePrivData);		
	}
	
	/**
	 * A shortcut to the key distribution module's private data.
	 * 
	 * @return a pointer to the privacy module's private data from the combinedData structure
	 */
	command KDCPrivData_t* SharedData.getKDCPrivData() {
		return &(combinedData.kdcPrivData);		
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
		if (!m_busy) {
			m_busy = TRUE;
			return call SharedDataWrite.erase();			
		}
		return EBUSY;
	}

    default event void ResourceArbiter.saveCombinedDataToFlashDone(error_t result) {}

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
	event void KeysDataWrite.writeDone(storage_addr_t addr, void *buf, storage_len_t len, error_t err) {
    	m_busy = FALSE;
	    memPosition += len;
		signal ResourceArbiter.saveKeyToFlashDone(err);
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
			return call SharedDataRead.read(0, &combinedData, sizeof(combinedData_t));
		}
		return EBUSY;
	}
	
    default event void ResourceArbiter.restoreCombinedDataFromFlashDone(error_t result) {}

	command error_t ResourceArbiter.saveKeyToFlash(nx_uint8_t * key) {
		if (!m_busy) {
			m_busy = TRUE;
			if (memPosition == 0) {
				currentKey = key;
				return call KeysDataWrite.erase();
			} else {
				return call KeysDataWrite.write(memPosition, key, KEY_LENGTH);
			}
		}
		return EBUSY;
	}
	
	default event void ResourceArbiter.saveKeyToFlashDone(error_t result) {}

	command error_t ResourceArbiter.restoreKeyFromFlash(uint8_t neighbourId){
		if (!m_busy) {
			m_busy = TRUE;
			return call KeysDataRead.read((neighbourId - 1) * KEY_LENGTH, currentKey, KEY_LENGTH);
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
	event void KeysDataRead.readDone(storage_addr_t addr, void *buf, storage_len_t len, error_t err) {
    	m_busy = FALSE;
	    signal ResourceArbiter.restoreKeyFromFlashDone(err);
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
	event void KeysDataRead.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error){
	}

	/**
     * Signals the completion of a sync operation. All written data is
     * flushed to non-volatile storage after this event.
     *
     * @param error SUCCESS if the operation was successful, FAIL if
     *   it failed
     */
	event void KeysDataWrite.syncDone(error_t error){
	}

	/**
   	 * Signals the completion of an erase operation.
   	 *
   	 * @param error SUCCESS if the operation was successful, FAIL if
   	 *   it failed
   	 */
	event void KeysDataWrite.eraseDone(error_t error){
		if (error == SUCCESS) {
				call KeysDataWrite.write(memPosition, currentKey, KEY_LENGTH);
		}
	}
		#endif

	command nx_uint8_t * ResourceArbiter.getCurrentKey() {
		return currentKey;
	}
	
	command uint32_t ResourceArbiter.getNumberOfStoredKeys() {
		//printf("number of stored keys: %d", (memPosition / KEY_LENGTH));
		return memPosition / KEY_LENGTH; 
	}
	
	event void SharedDataRead.readDone(storage_addr_t addr, void *buf, storage_len_t len, error_t err) {
		m_busy = FALSE;
	}
	
	/**
	 * Called after initialize to save the combined data initial values to EEPROM
	 */
	event void SharedDataWrite.eraseDone(error_t error){
		call SharedDataWrite.write(0, &combinedData, sizeof(combinedData_t));
	}
	
	event void SharedDataRead.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error){
	}
	
	event void SharedDataWrite.writeDone(storage_addr_t addr, void *buf, storage_len_t len, error_t err) {
    	m_busy = FALSE;
    	signal ResourceArbiter.restoreCombinedDataFromFlashDone(err);
   	}
   	
   	/**
     * Signals the completion of a sync operation. All written data is
     * flushed to non-volatile storage after this event.
     *
     * @param error SUCCESS if the operation was successful, FAIL if
     *   it failed
     */
	event void SharedDataWrite.syncDone(error_t error){
	}
}

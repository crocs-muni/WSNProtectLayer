interface ResourceArbiter {
	/**
	 * A command to backup the entire combinedData structure to the flash memory
	 * 
	 * @return 
	 * <li>SUCCESS if the request was accepted, 
	 * <li>EINVAL if the parameters are invalid
	 * <li>EBUSY if a request is already being processed.
	 */
	command error_t saveCombinedDataToFlash();

	/**
	 * Signals the completion of a write operation. However, data is not
	 * guaranteed to survive a power-cycle unless a sync operation has
	 * been completed.
	 *
	 * @param result SUCCESS if the operation was successful, FAIL if
	 *   it failed
	 */
	event void saveCombinedDataToFlashDone(error_t result);

	//TODO? command error_t getPtr(); 

	/**
	 * A command to restore the saved combinedData structure form the flash memory
	 * and rewrite the current data in combinedData.
	 * 
	 * @return 
	 *   <li>SUCCESS if the request was accepted, 
	 *   <li>EINVAL if the parameters are invalid
	 *   <li>EBUSY if a request is already being processed.
	 */
	command error_t restoreCombinedDataFromFlash();

	/**
	 * Signals the completion of a read operation.
	 *
	 * @param result SUCCESS if the operation was successful, FAIL if
	 *   it failed
	 */
	event void restoreCombinedDataFromFlashDone(error_t result);

	/**
	 * Store key to flash
	 * @param key pointer to the memory block of size <i>KEY_LENGTH</i> to be saved
	 */
	command error_t saveKeyToFlash(nx_uint8_t * key);

	/**
	 * Signals the completion of write key operation.
	 * 
	 * @param result SUCCESS if the operation was successful, FAIL if
	 *   it failed
	 */
	event void saveKeyToFlashDone(error_t result);
	
	/**
	 * A command to restore the saved combinedData structure form the flash memory
	 * and rewrite the current data in combinedData.
	 * 
	 * @param neighbourId identification of the neighbour, i.e. i-th block of size <i>KEY_LENGTH</i> to be read
	 * 
	 * @return 
	 *   <li>SUCCESS if the request was accepted, 
	 *   <li>EINVAL if the parameters are invalid
	 *   <li>EBUSY if a request is already being processed.
	 */
	command error_t restoreKeyFromFlash(uint8_t neighbourId);

	/**
	 * Signals the completion of a read operation.
	 *
	 * @param result SUCCESS if the operation was successful, FAIL if
	 *   it failed
	 */
	event void restoreKeyFromFlashDone(error_t result);
	
	/**
	 * Pointer to the last key read from memory or the first key to be written to memory.
	 * 
	 * @return pointer to the last key
	 */
	command nx_uint8_t * getCurrentKey();
	
	/**
	 * @return number of keys stored to the flash memory
	 */
	command uint32_t getNumberOfStoredKeys();
}
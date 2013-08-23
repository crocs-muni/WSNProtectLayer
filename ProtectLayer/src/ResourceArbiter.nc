interface ResourceArbiter {
	/**
	 * A command to backup the entire combinedData structure to the flash memory
	 * 
	 * @return 
     * <li>SUCCESS if the request was accepted, 
     * <li>EINVAL if the parameters are invalid
     * <li>EBUSY if a request is already being processed.
	 */
	command error_t backupToFlash();
	
	/**
     * Signals the completion of a write operation. However, data is not
     * guaranteed to survive a power-cycle unless a sync operation has
     * been completed.
     *
     * @param result SUCCESS if the operation was successful, FAIL if
     *   it failed
     */
	event void backupToFlashDone(error_t result);
	
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
	command error_t restoreFromFlash();
	
	/**
   * Signals the completion of a read operation.
   *
   * @param result SUCCESS if the operation was successful, FAIL if
   *   it failed
   */
	event void restoreFromFlashDone(error_t result);
}
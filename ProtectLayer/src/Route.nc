/**
 * Interface that provides basic commands necessary for packet forwarding. 
 * 
 * 	@version   0.1
 * 	@date      2012-2013 
 */

#include "ProtectLayerGlobals.h"
interface Route{
	/**
	 * Command that returns the ID of single parent node. 
	 * 
	 * @returns Single parent node ID 
	 */
	command node_id_t getParentID();
	
	/**
	 * Returns random neighbor. Blocking variant.
	 * 
	 * 
	 * @param neigh		random neighbor is provided via this parameter.
	 */
	command error_t getRandomNeighborIDB(node_id_t * neigh);
	
	/**
	 * Returns CTP parent. Blocking variant.
	 * 
	 * 
	 * @param neigh		CTP parent.
	 */
	command error_t getCTPParentIDB(node_id_t * parent);
	
	/**
	 * Command that requests the ID of randomly chosen parent node. 
	 * If the command returns SUCCESS, then the component will signal the randomParentIDprovided event in the future;
	 * if send returns an error, it will not signal the randomParentIDProvided. 
	 * If the component accepts a request for ID and later it cannot provide the ID, it will signal the event
	 * randomParentIDprovided with an appropriate error code.   
	 * 
	 * @returns SUCCESS if it accepts the request, FAIL otherwise.  
	 */
	command error_t getRandomParentID();
	
	/**
	 * Event is signaled as a response to getRandomParentID command. It provides random parent node ID.
	 * 
	 * @params status	error_t value is SUCCESS if everything was ok and FAIL otherwise
	 * @params id 		node_id_t random parent node ID is valid if status is SUCCESS and undefined if status is FAILED 
	 * 
	 * @see getRandomParentID()
	 * 
	 */
	
	
	event void randomParentIDprovided(error_t status, node_id_t id);
	
	/**
	 * Command that requests the ID of randomly chosen neighbor node. 
	 * If the command returns SUCCESS, then the component will signal the randomNeighborIDprovided event in the future;
	 * if send returns an error, it will not signal the randomNeighborIDprovided. 
	 * If the component accepts a request for ID and later it cannot provide the ID, it will signal the event
	 * randomNeighborIDprovided with an appropriate error code.   
	 * 
	 * @returns SUCCESS if it accepts the request, FAIL otherwise.  
	 */
	command error_t getRandomNeighborID();
	
	/**
	 * Event is signaled as a response to getRandomNeighborID command. It provides random neighbor node ID.
	 * 
	 * @params status	error_t value is SUCCESS if everything was ok and FAIL otherwise
	 * @params id 		node_id_t random neighbor node ID is valid if status is SUCCESS and undefined if status is FAILED 
	 * 
	 * @see getRandomNeighborID()
	 * 
	 */
	event void randomNeighborIDprovided(error_t status, node_id_t id);
	/*
	command error_t getParentIDs(node_id_t* ids, uint8_t maxCount);
	event void parentIDsProvided(error_t status, node_id_t* ids, uint8_t resultCount);
	
	command error_t getChildrenIDs(node_id_t* ids, uint8_t maxCount);
	event void childrenIDsProvided(error_t status, node_id_t* ids, uint8_t resultCount);
	
	command error_t getNeighborIDs(node_id_t* ids, uint8_t maxCount);
	event void neighborIDsProvided(error_t status, node_id_t* ids, uint8_t resultCount);
	*/
}

/** 
 *  Interface for functions related to key distribution.
 *  This interface specifies functions available in split-phase manner related to key distribution. New key discovery to direct neigbor can be initiated and key to base station or other node can be obtained.
 * 	@version   0.1
 * 	@date      2012-2013
 */
#include "ProtectLayerGlobals.h"
interface KeyDistrib {
	/**
		Command: Posts taks for key task_discoverKeys for key discovery
		@return error_t status. SUCCESS or EALREADY if already pending
	*/
	command error_t discoverKeys();
	/**
		Event: Signalized when KeyDistrib.discoverKeys task was finished. After signal, all nodes should have pairwise keys established 
		@param[out] error_t status returned by task_discoverKeys task
		@return nothing
	*/	
	event void discoverKeysDone(error_t result);
	
	command PL_key_t* getKeyToNodeB(uint8_t nodeID);
	command PL_key_t* getKeyToBSB(uint8_t nodeID);	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

/*** DEPRICATED ***/


	/**
		Command: Posts task for obtaining key to base station
		@return error_t status. SUCCESS or EALREADY if already pending	
	*/	
	command error_t getKeyToBS();
	/**
		Event: Signalized when KeyDistrib.getKeyToBSDone task was finished. After signal, returned key can be used toencrypt messages for base station
		@param[out] resultreturned by task_getKeyToBS
		@param[out] pBSKey handle to key shared between node and base station
		@return nothing
	*/	
	event void getKeyToBSDone(error_t result, PL_key_t* pBSKey);

	/**
		Task: Post task for obtaining key between current node and  other node specified by it's nodeID
		Signal: KeyDistrib.getKeyToNodeDone
		@param[in] nodeID node identification of node for which the key should be searched for
		@return error_t status. SUCCESS or EALREADY if already pending
	*/	
	command error_t getKeyToNode(uint8_t nodeID);
	/**
		Event: Signalized when KeyDistrib.getKeyToNodeDone task was finished
		@param[out] result returned by task_getKeyToNode
		@param[out] pNodeKey handle to key shared between this node and specified node returned
		@return nothing
	*/	
	event void getKeyToNodeDone(error_t result, PL_key_t* pNodeKey);

}

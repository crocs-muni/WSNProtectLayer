/** 
 *  Interface for functions related to key distribution.
 *  This interface specifies functions available in split-phase manner related to key distribution. New key discovery to direct neigbor can be initiated and key to base station or other node can be obtained.
 * 	@version   1.0
 * 	@date      2012-2014
 */
#include "ProtectLayerGlobals.h"
interface KeyDistrib {
	/**
		Command: Posts taks for key task_discoverKeys for key discovery
		@return error_t status. SUCCESS or EALREADY if already pending
	*/
	command error_t discoverKeys();
	
	
	/**
		Command: Get key to node.
		@param[in] nodeID node identification of node for which the key should be searched for
		@param[out] pNodeKey handle to key shared between node and base station 
		@return error_t status.
	*/	
	command error_t getKeyToNodeB(uint8_t nodeID, PL_key_t** pNodeKey);
	
	/**
		Command: Get key to base station
		@param[out] pBSKey handle to key shared between node and base station 
		@return error_t status.
	*/
	command error_t getKeyToBSB(PL_key_t** pBSKey);	
	
	
	/**
		Command: Get key for AES based hashing function 
		@param[out] pBSKey handle to key
		@return error_t status.
	*/
	command error_t getHashKeyB(PL_key_t** pHashKey);	
	
	/**
		Command: selftest provides possibility to test functionality of KeyDistrib component
		@return: error_t status
	*/
	command error_t selfTest();
}

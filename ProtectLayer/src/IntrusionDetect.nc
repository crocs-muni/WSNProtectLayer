/**
 * Interface Intrusion Detect provides commands for IDS management.
 *  @version   0.1
 * 	@date      2012-2013
 */

#include "ProtectLayerGlobals.h"
interface IntrusionDetect {
	// TODO: add other methods that may provide finer control over Intrusion detection component
	
	/**
	 * Command that returns reputation of node "nodeId"
	 * 
	 * @param nodeId ID of node
	 * 
	 * @returns NODE_REPUTATION reputation of a node.
	 */
//	command NODE_REPUTATION getNodeReputation(uint8_t nodeId);
	
	/**
	 * Command that switch the IDS off
	 */
	command void switchIDSoff();
	
	/**
	 * Command that switch the IDS on
	 */
	command void switchIDSon();
	
	/**
	 * Command that reset the IDS
	 */
	command void resetIDS();
}

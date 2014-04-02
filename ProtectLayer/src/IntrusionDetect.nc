/**
 * Interface Intrusion Detect provides commands for IDS management.
 *  @version   0.1
 * 	@date      2012-2013
 */

#include "ProtectLayerGlobals.h"
interface IntrusionDetect {
	
	/**
	 * Command that returns reputation of node "nodeId"
	 * 
	 * @param nodeId ID of node
	 * 
	 * @returns NODE_REPUTATION reputation of a node.
	 */
	
	/**
	 * Command that switches the IDS off.
	 */
	command void switchIDSoff();
	
	/**
	 * Command that switches the IDS on.
	 */
	command void switchIDSon();
	
	/**
	 * Command that resets the IDS - it erases the IDS Buffer. 
	 */
	command void resetIDS();
}

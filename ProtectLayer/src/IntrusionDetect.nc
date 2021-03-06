/**
 * Interface Intrusion Detect provides commands for IDS management.
 *  @version   1.0
 * 	@date      2012-2014
 */

#include "ProtectLayerGlobals.h"
interface IntrusionDetect {
	
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

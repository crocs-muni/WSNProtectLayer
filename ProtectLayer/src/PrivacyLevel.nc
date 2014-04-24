/**
 * Interface PrivacyLevel provides functionality for management of privacy levels. 
 * 
 * 	@version   1.0
 * 	@date      2012-2014
 * 
 */

#include "ProtectLayerGlobals.h"
interface PrivacyLevel{
	
	/**
	 * Event is signaled upon a privacy level is changed. Usually upon a receipt of a proper message.
	 * 
	 * @param status 			the error_t status returned
	 * @param newPrivacyLevel 	the new PRIVACY_LEVEL after change
	 * 
	 */
	event void privacyLevelChanged(error_t status, PRIVACY_LEVEL newPrivacyLevel);

}
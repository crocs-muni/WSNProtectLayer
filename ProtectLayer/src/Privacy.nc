/**
 *
 * Interface Privacy provides commands for privacy management. 
 * 	@version   0.1
 * 	@date      2012-2013
 */




#include "ProtectLayerGlobals.h"
interface Privacy {
	/**
	 * Command that returns current privacy level.
	 * 
	 * 
	 * @returns Current privacy level. 
	 */
	command PRIVACY_LEVEL getCurrentPrivacyLevel();
	
	
	/**
	 * Signalize to the application ProtectLayer initialization
	 * result.
	 * 
	 * @param error State of the PL initialization
	 */
	command void startApp(error_t error);
}

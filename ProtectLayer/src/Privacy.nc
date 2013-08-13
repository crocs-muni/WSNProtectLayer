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
}

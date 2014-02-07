/**
 * Interface for signalizing magic packet was received.
 * 
 * 	@version   0.1
 * 	@date      2012-2013
 * 
 */

#include "ProtectLayerGlobals.h"
interface MagicPacket{
	
	/**
	 * Event is signaled upon a privacy level is changed for the first time.
	 * 
	 * @param status 			the error_t status returned
	 * @param newPrivacyLevel 	the new PRIVACY_LEVEL after change
	 * 
	 */
	event void magicPacketReceived(error_t status, PRIVACY_LEVEL newPrivacyLevel);
}
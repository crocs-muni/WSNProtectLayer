/**
 * Interface IDSBuffer provides command for management of the buffer used by IDS 
 */

#include "ProtectLayerGlobals.h"
interface IDSBuffer{
	
	/**
	 * Event signaling that oldest packet (not forwarded) was removed (dropped)
	 */
	event void oldestPacketRemoved(uint16_t sender, uint16_t receiver);
	
	event void packetForwarded(uint16_t sender, uint16_t receiver);	
	
	command void insertOrUpdate(idsBufferedPacket_t idsBP);
}
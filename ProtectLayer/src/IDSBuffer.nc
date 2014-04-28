/**
 * Interface IDSBuffer provides command for management of the buffer used by IDS 
 */

#include "ProtectLayerGlobals.h"
interface IDSBuffer{
	
    /**
     * An event signaled from IDSBuffer informing about a dropped packet.
     * 
     * @param sender id of a node that sent the dropped packet
     * @param receiver id of a node that did not forward the dropped packet
     */
	event void oldestPacketRemoved(uint16_t sender, uint16_t receiver);
	
    /**
     * An event signaled from IDSBuffer informing about a forwarded packet.
     * 
     * @param sender id of a node that sent the forwarded packet
     * @param receiver id of a node that forwarded the forwarded packet
     */	
	event void packetForwarded(uint16_t sender, uint16_t receiver);	
	
	/**
	 * A command used to insert (or update) a packet to the buffer
	 * 
	 * @param sender id of a node that sent the packet
	 * @param receiver id of a node that was a receiver of the packet
	 * @param hashedPacket computed hash of the packet payload that is stored in the buffer
	 */
	command void insertOrUpdate(uint16_t* sender, uint16_t* receiver, uint32_t* hashedPacket);
	
	/**
	 * A command that is used to reset statistics of the IDS
	 */
	command void resetBuffer();
}
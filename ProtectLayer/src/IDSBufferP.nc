#include "ProtectLayerGlobals.h"

module IDSBufferP{
	uses {
		interface SharedData;
	}
	provides {
		interface IDSBuffer;
	}
}

implementation{
	
	// IDS Buffer
	idsBufferedPacket_t idsBuffer[IDS_BUFFER_SIZE];
	idsBufferedPacket_t packetToBuffer;
	// Pointer to the oldest packet in the index
	uint8_t oldestPacketIndex = 0;
	uint8_t counter = 0;
	void insertPacket(uint16_t* sender, uint16_t* receiver, uint64_t* hashedPacket);
	void removeForwardedPacket(uint16_t* sender, uint16_t* receiver, uint64_t* hashedPacket, uint8_t id);
	void removeOldestPacket();

	command void IDSBuffer.insertOrUpdate(uint16_t* sender, uint16_t* receiver, uint64_t* hashedPacket){

		uint8_t i;
		
		// Is this packet addressed to monitored neighbor? => buffer it!
		if (call SharedData.getNodeState(*receiver) != NULL) {
			// Is the buffer full?
			if (counter == IDS_BUFFER_SIZE) {
				removeOldestPacket();
			}
			// Insert packet!
			insertPacket(sender, receiver, hashedPacket);			
		}

		// Is this packet sent by monitored neighbor? => update buffer!
		if (call SharedData.getNodeState(*sender) != NULL) {
			// Is this packet already stored in the buffer?
			for (i = 0; i < counter; i++) {
				if (*hashedPacket == idsBuffer[i].hashedPacket && *sender == idsBuffer[i].receiver) {
					// Mark the packet as forwarded and remove it from the buffer
					removeForwardedPacket(sender, receiver, hashedPacket, i);

					return;
				}
			}
		}
		
	}
	
	void insertPacket(uint16_t* sender, uint16_t* receiver, uint64_t* hashedPacket) {
		packetToBuffer.hashedPacket = *hashedPacket;
		packetToBuffer.sender = *sender;
		packetToBuffer.receiver = *receiver;
		idsBuffer[counter] = packetToBuffer;
		counter++;
	}
	
	void removeForwardedPacket(uint16_t* sender, uint16_t* receiver, uint64_t* hashedPacket, uint8_t id) {
		uint8_t i;
		
		if (counter == 0) {
			return;
		}
		
		signal IDSBuffer.packetForwarded(idsBuffer[id].sender, idsBuffer[id].receiver);
		
			
		// Remove the gap after the forwarded packet!
		// Effectiveness can be improved here:
        counter--;
		for(i = id; i < counter; i++) {
        	memcpy(&idsBuffer[i], &idsBuffer[i + 1], sizeof(idsBufferedPacket_t));
        }
	}
	
	void removeOldestPacket() {
		uint8_t i;
		signal IDSBuffer.oldestPacketRemoved(idsBuffer[oldestPacketIndex].sender, idsBuffer[oldestPacketIndex].receiver);
		// Chech counter if oldestPacketIndex used
		counter--;
		for(i = oldestPacketIndex % IDS_BUFFER_SIZE; i < counter; i++) {
        	memcpy(&idsBuffer[(i + oldestPacketIndex) % IDS_BUFFER_SIZE], &idsBuffer[(i + oldestPacketIndex + 1) % IDS_BUFFER_SIZE], sizeof(idsBufferedPacket_t));
        }
		// To improve effectiveness, check following:
//		oldestPacketIndex == (oldestPacketIndex + 1) % IDS_BUFFER_SIZE;
	}
}
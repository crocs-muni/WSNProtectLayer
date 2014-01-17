#include "ProtectLayerGlobals.h"

module IDSBufferP{
	provides {
		interface IDSBuffer;
	}
}

implementation{
	
	// IDS Buffer
	idsBufferedPacket_t idsBuffer[IDS_BUFFER_SIZE];
	// Pointer to the oldest packet in the index
	uint8_t oldestPacketIndex = 0;
	uint8_t counter = 0;
	void insertPacket(idsBufferedPacket_t idsBP);
	void removeForwardedPacket(idsBufferedPacket_t idsBP, uint8_t id);
	void removeOldestPacket();

	command void IDSBuffer.insertOrUpdate(idsBufferedPacket_t idsBP){

		uint8_t i;

		// Is this packet already stored in the buffer?
		for (i = 0; i < counter; i++) {
			if (idsBP.hashPacket == idsBuffer[i].hashPacket) {
				// Mark the packet as forwarded and remove it from the buffer
				removeForwardedPacket(idsBP, i);

				return;
			}
		}
		
		// Is the buffer full?
		if (counter == IDS_BUFFER_SIZE) {
			removeOldestPacket();
		}
		insertPacket(idsBP);

	}
	
	void insertPacket(idsBufferedPacket_t idsBP) {
		counter++;
		idsBuffer[counter] = idsBP;
	}
	
	void removeForwardedPacket(idsBufferedPacket_t idsBP, uint8_t id) {
		uint8_t i;
		
		signal IDSBuffer.packetForwarded(idsBuffer[id].sender, idsBuffer[id].receiver);
		
		// TODO: Zkontrolovat for cyklus!
		for(i = (id - oldestPacketIndex) % IDS_BUFFER_SIZE; i < counter; i++) {
        	memcpy(&idsBuffer[(i + oldestPacketIndex) % IDS_BUFFER_SIZE], &idsBuffer[(i + oldestPacketIndex + 1) % IDS_BUFFER_SIZE], sizeof(idsBufferedPacket_t));
        } 
	}
	
	void removeOldestPacket() {
		signal IDSBuffer.oldestPacketRemoved(idsBuffer[oldestPacketIndex].sender, idsBuffer[oldestPacketIndex].receiver);
		
		counter--;
		oldestPacketIndex == (oldestPacketIndex + 1) % IDS_BUFFER_SIZE;
	}
}
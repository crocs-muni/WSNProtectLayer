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
	void insertPacket(uint16_t* sender, uint16_t* receiver, uint32_t* hashedPacket);
	void removeForwardedPacket(uint16_t* sender, uint16_t* receiver, uint32_t* hashedPacket, uint8_t id);
	void removeOldestPacket();

 	// Logging tag for this component
    static const char *TAG = "IDSBufferP";

	command void IDSBuffer.resetBuffer() {
		oldestPacketIndex = 0;
		counter = 0;
	}

	command void IDSBuffer.insertOrUpdate(uint16_t* sender, uint16_t* receiver, uint32_t* hashedPacket){

		uint8_t i;
		
		// Is this packet addressed to monitored neighbor? => buffer it!
		if (call SharedData.getNodeState(*receiver) != NULL && *receiver != TOS_BS_NODE_ID) {
			pl_log_i(TAG, "IDSBuffer: receiver %d of this packet is monitored -> buffer the packet!\n", *receiver);
			// Is the buffer full?
			if (counter == IDS_BUFFER_SIZE) {
				pl_log_i(TAG, "IDSBuffer: IDS buffer is full -> remove oldest packet.\n");
				removeOldestPacket();
			}
			// Insert packet!
			insertPacket(sender, receiver, hashedPacket);			
		}

		// Is this packet sent by monitored neighbor? => update buffer!
		if (call SharedData.getNodeState(*sender) != NULL && *sender != TOS_BS_NODE_ID) {
			pl_log_i(TAG, "IDSBuffer: sender %d of this packet is monitored -> update the buffer!\n", *sender);
			// Is this packet already stored in the buffer?
			for (i = 0; i < counter; i++) {
				pl_log_i(TAG, "IDSBuffer: hash is: %lu, hash in the buffer is: %lu\n.", *hashedPacket, idsBuffer[i].hashedPacket);
				pl_log_i(TAG, "IDSBuffer: node sending is %d and buffered receiver is %d.\n", *sender, idsBuffer[i].receiver);
				
				if (*hashedPacket == idsBuffer[i].hashedPacket && *sender == idsBuffer[i].receiver) {
					
					pl_log_i(TAG, "IDSBuffer: packet found in the buffer\n.");
					
					// Mark the packet as forwarded and remove it from the buffer
					removeForwardedPacket(sender, receiver, hashedPacket, i);

					return;
				}
			}
		}
		
	}
	
	void insertPacket(uint16_t* sender, uint16_t* receiver, uint32_t* hashedPacket) {
		packetToBuffer.hashedPacket = *hashedPacket;
		packetToBuffer.sender = *sender;
		packetToBuffer.receiver = *receiver;
		idsBuffer[counter] = packetToBuffer;
		counter++;
		pl_log_i(TAG, "IDSBuffer: Packet inserted, hash is %lu IDS buffer contains %d packets.\n", packetToBuffer.hashedPacket, counter);
	}
	
	void removeForwardedPacket(uint16_t* sender, uint16_t* receiver, uint32_t* hashedPacket, uint8_t id) {
		uint8_t i;
		
		pl_log_i(TAG, "IDSBuffer: removeForwardedPacket called\n.");
		
		if (counter == 0) {
			return;
		}
		
		signal IDSBuffer.packetForwarded(*sender, *receiver);
		
			
		// Remove the gap after the forwarded packet!
		// Effectiveness could be improved here, but we are limited in memory for the code:
        counter--;
		for(i = id; i < counter; i++) {
        	memcpy(&idsBuffer[i], &idsBuffer[i + 1], sizeof(idsBufferedPacket_t));
        }
        pl_log_i(TAG, "IDSBuffer: Forwarded packet removed, IDS buffer contains %d packets.\n", counter);
	}
	
	void removeOldestPacket() {
		uint8_t i;
		signal IDSBuffer.oldestPacketRemoved(idsBuffer[oldestPacketIndex].sender, idsBuffer[oldestPacketIndex].receiver);
		// Chech counter if oldestPacketIndex used
		counter--;
		for(i = oldestPacketIndex % IDS_BUFFER_SIZE; i < counter; i++) {
        	memcpy(&idsBuffer[(i + oldestPacketIndex) % IDS_BUFFER_SIZE], &idsBuffer[(i + oldestPacketIndex + 1) % IDS_BUFFER_SIZE], sizeof(idsBufferedPacket_t));
        }
        
        pl_log_i(TAG, "IDSBuffer: Oldest packet removed, IDS buffer contains %d packets.\n", counter);
		// To improve effectiveness, check following:
//		oldestPacketIndex == (oldestPacketIndex + 1) % IDS_BUFFER_SIZE;
	}
}
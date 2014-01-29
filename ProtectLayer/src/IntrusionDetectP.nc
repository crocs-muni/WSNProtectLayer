/**
 * Module IntrusionDetectP implements interfaces provided by configuration IntrusionDetectC.
 * 	@version   0.1
 * 	@date      2012-2013
 */

#include "ProtectLayerGlobals.h"
#include "printf.h"

module IntrusionDetectP {
    uses {
        //		interface AMSend;
        //		interface Receive;
        interface Receive as ReceiveMsgCopy;
        interface Receive as ReceiveIDSMsgCopy;
        interface SharedData;
        //		interface Timer<TMilli> as TimerIDS;
        //		interface BlockWrite;
        interface IDSBuffer;
        interface AMSend;// as IDSAlertSend;
        interface Crypto;
        interface AMPacket;
        interface Packet;
    }
    provides {
        interface Init;
        interface Init as PLInit;
        interface IntrusionDetect;
    }
}

implementation {
    message_t m_msg;
    
    // Logging
    message_t* m_logMsg;
    message_t* m_lastLogMsg;
    message_t m_memLogMsg;
    message_t pkt;
    //	bool m_storageBusy = FALSE;
    
    bool m_radioBusy = FALSE;
    //	combinedData_t * combinedData;
    SavedData_t*    pSavedData = NULL;
    NODE_REPUTATION reputation;
    SavedData_t* savedData;
    IDS_STATUS ids_status = IDS_RESET;
    //	uint32_t offset_write = 0;
    
    
    //
    //	Init interface
    //
    command error_t Init.init() {
        // TODO: do other initialization
        // TODO: how will we collect the data from SharedData

            printf("IDSState: IDS initialization called.\n"); printfflush();

        //call TimerIDS.startPeriodic(1024);
        
        m_logMsg = &m_memLogMsg;
        
        return SUCCESS;
    }
    
    //	command NODE_REPUTATION IntrusionDetect.getNodeReputation(uint8_t nodeid) {
    //		//savedData = call SharedData.getNodeState(nodeid);
    //		//reputation = (*savedData).idsData.neighbor_reputation;
    //		reputation =  (*call SharedData.getNodeState(nodeid)).idsData.neighbor_reputation;
    //                dbg("IDSState", "Reputation of node %d is: %d.\n", nodeid, reputation);
    //		return reputation;
    //	}
    
    command error_t PLInit.init()
    {
        //combinedData = call SharedData.getAllData();
        pSavedData = call SharedData.getSavedData();
        return SUCCESS;
    }
    
    command void IntrusionDetect.switchIDSoff(){
        // TODO implementation
        ids_status = IDS_OFF;
    }
    
    command void IntrusionDetect.switchIDSon(){
        // TODO implementation
        ids_status = IDS_ON;
    }
    
    command void IntrusionDetect.resetIDS(){
        // TODO implementation
        ids_status = IDS_RESET;
    }
    
    // TODO: IDS component will send messages using tasks and will check the error code, if fail, the same task will be generated again.
    
    //	event void AMSend.sendDone(message_t* msg, error_t status){
    //		if (msg==&m_msg) {
    //			m_radioBusy = FALSE;
    //		}
    //	}
    
    //	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
    //		
    //		if (len == sizeof(IDSMsg_t)) {
    //			
    //			
    //			IDSMsg_t* idsmsg = (IDSMsg_t*) payload;
    //                        dbg("IDSState", "Packet received. Receiver: %d. Broadcast address: %d. Reputation: %d\n", idsmsg->receiver, AM_BROADCAST_ADDR, idsmsg->reputation);
    //			
    //			/* is the message for me? */
    //			// TODO: finalize this part!!
    //			if (TOS_NODE_ID == idsmsg->receiver || idsmsg->receiver == AM_BROADCAST_ADDR) {
    //			
    //				/* somebody requested to know reputation of one of my neighbor */
    //				if (idsmsg->reputation == 0) {
    //                                        dbg("IDSState", "Node %d wants to know reputation of node %d.\n", idsmsg->sender, idsmsg->nodeID);
    //					// TODO: reaction - send the reputation! Split-phase: will be done in a task.
    //				}
    //				
    //				/* somebody sent me reputation of one of its neighbor */
    //				else {
    //                                        dbg("IDSState", "Node %d says: the reputation of node %d is %d.\n", idsmsg-> sender, idsmsg->nodeID, idsmsg->reputation);
    //					// TODO: reaction - store the reputation or combine it with its own collected reputation!
    //				}
    //			
    //			}
    //			
    //		}
    //
    //		return msg;
    //	}
    
    //	task void task_sendMessage() {
    //	  	error_t rval=SUCCESS;
    //		
    //		rval = call AMSend.send(AM_BROADCAST_ADDR, &m_msg, sizeof(IDSMsg_t));
    //	    if (rval == SUCCESS) {
    //	        m_radioBusy = TRUE;
    //                        dbg("IDSState", "IDS: IntrusionDetectP.task_sendMessage send returned %d.\n",rval);
    //	        return;
    //	    }
    //		return;
    //	}
    
    // Testing purposes
    //	event void TimerIDS.fired(){
    //		error_t rval;
    //
    //                dbg("IDSState", "IDS timer fired. My time: %d.\n", call TimerIDS.getNow());
    //		
    //		
    //	    if (!m_radioBusy) {
    //		      IDSMsg_t* idsmsg = (IDSMsg_t*)(call AMSend.getPayload(&m_msg, sizeof(IDSMsg_t)));
    //		      if (idsmsg == NULL) {
    //				return;
    //		      }
    //		      
    //		      idsmsg->sender = TOS_NODE_ID;
    //		      idsmsg->receiver = AM_BROADCAST_ADDR;
    //		      idsmsg->nodeID = 7; // send me reputation of node 7.
    //		      idsmsg->reputation = 0; // I am asking for reputation.
    //		      dbg("IDSState", "The receiver will be: %d\n", idsmsg->receiver);
    //		      // send message
    //		      rval = call AMSend.send(AM_BROADCAST_ADDR, &m_msg, sizeof(IDSMsg_t));
    //			  if (rval == SUCCESS) {
    //			      m_radioBusy = TRUE;
    //			    }
    //			}
    //	}
    
    
    // Messages passed to the IDS from privacy component
    event message_t * ReceiveMsgCopy.receive(message_t *msg, void *payload, uint8_t len){
        
        //        printf("IDS: ReceiveMsgCopy.receive\n"); printfflush();
        
        //		uint8_t msgType;
        uint64_t hashedPacket;
        
        SPHeader_t* spHeader;        
        spHeader = (SPHeader_t*) payload;

            printf("IDSState: A copy of a message from Privacy component received.\n"); printfflush();

        
        if (call SharedData.getNodeState(spHeader->sender) == NULL && call SharedData.getNodeState(spHeader->receiver) == NULL ) {
            return msg;
        }
        
        savedData = call SharedData.getNodeState(spHeader->sender);
        savedData->idsData.nb_received++;
        
        //        msgType = spHeader->msgType;
        
        call Crypto.hashDataHalfB( (uint8_t*) payload, 0, len, &hashedPacket);
        
        // AES (or another cryptographic function) of the payload should be computed in order
        // to identify content of the messages
        // Buffer for each of the node will contain:
        // Sender id, Receiver id, Content, RSSI?
        call IDSBuffer.insertOrUpdate(&spHeader->sender, &spHeader->receiver, &hashedPacket);
        
        
        return msg;
        
        /* This was used for logging to EEPROM - will not be used any more
        //is storage busy?
        if (m_storageBusy)
        {
            // storage busy, packet cannot be logged
            return msg; 	
        }
        else
        {
                        //printf("IntrusionDetectP: Going to write\n"); printfflush();
                        
                        //log packet
            m_lastLogMsg = msg;
            if (call BlockWrite.write(offset_write, payload, LOGGED_SIZE) == SUCCESS)
            {
                m_storageBusy = TRUE;
                offset_write += LOGGED_SIZE;
                return m_logMsg;
            }
            else
            {
                //logging failed, return original msg
                return msg;
            }
        }
        */
        
    }
    
    //	event void BlockWrite.eraseDone(error_t error){
    //	}
    //
    //	event void BlockWrite.writeDone(storage_addr_t addr, void *buf, storage_len_t len, error_t error){
    //		// TODO: chech whether payload == buf
    //            //printf("IntrusionDetectP: BlockWrite.writeDone executed with %d\n", error); printfflush();
    
    //            if printf(error == SUCCESS) ("IntrusionDetectP: writeDone success\n"); printfflush();
    
    //            else printf("IntrusionDetectP: writeDone fail with %d \n", error); printfflush();
    
    //
    //            m_logMsg = m_lastLogMsg;
    //            m_storageBusy = FALSE;
    //
    //	}
    //
    //	event void BlockWrite.syncDone(error_t error){
    //	}
    
    event void IDSBuffer.oldestPacketRemoved(uint16_t sender, uint16_t receiver){
        
        IDSMsg_t* idspkt;
        
        savedData = call SharedData.getNodeState(receiver);

            printf("IDSState: Neighbor %d dropped a packet. IDS alert will be sent.\n", receiver); printfflush();

        
        
        if (savedData->idsData.nb_received > IDS_MIN_PACKET_RECEIVED) {
            if ( (savedData->idsData.nb_forwarded * 100 / savedData->idsData.nb_received) < IDS_DROPPING_THRESHOLD ) {
                if (!m_radioBusy) {
                    idspkt = (IDSMsg_t*)(call Packet.getPayload(&pkt, sizeof(IDSMsg_t)));
                    if (idspkt == NULL) {
                        return;
                    }
                    idspkt->nodeID = receiver;
                    idspkt->dropping = savedData->idsData.nb_forwarded * 100 / savedData->idsData.nb_received;
                    
                    if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(IDSMsg_t)) == SUCCESS) {
                        m_radioBusy = TRUE;
                    }
                }	
            }
        }
    }
    
    event void IDSBuffer.packetForwarded(uint16_t sender, uint16_t receiver){
        savedData = call SharedData.getNodeState(sender);
        savedData->idsData.nb_forwarded++;

            printf("IDSState: Neighbor %d forwarded packet.\n", sender); printfflush();

    }
    
    /**
     * Event: Some IDS alert was received from Dispatcher - IDS alert
     */
    event message_t * ReceiveIDSMsgCopy.receive(message_t *msg, void *payload, uint8_t len){
        uint64_t hashedPacket;
        uint16_t sender = call AMPacket.source(msg);
        uint16_t receiver = call AMPacket.destination(msg);

            printf("IDSState: A copy of an IDSAlert from IDSForwarder received. Sender: %d, receiver: %d.\n", sender, receiver); printfflush();

        
        if (call SharedData.getNodeState(sender) == NULL && call SharedData.getNodeState(receiver) == NULL ) {
            return msg;
        }
        
        if ( (savedData = call SharedData.getNodeState(receiver)) != NULL) {
            (*savedData).idsData.nb_received++;

            printf("IDSState: Receiver %d is our neighbor, PRR incremented.\n", receiver); printfflush();

        }
        
        call Crypto.hashDataHalfB( (uint8_t*) payload, 0, len, &hashedPacket);
        
        // AES (or another cryptographic function) of the payload should be computed in order
        // to identify content of the messages
        // Buffer for each of the node will contain:
        // Sender id, Receiver id, Content, RSSI?
        call IDSBuffer.insertOrUpdate(&sender, &receiver, &hashedPacket);
        
        return msg;
    }
    
    
    event void AMSend.sendDone(message_t *msg, error_t error){
        m_radioBusy = FALSE;
    }
    
}

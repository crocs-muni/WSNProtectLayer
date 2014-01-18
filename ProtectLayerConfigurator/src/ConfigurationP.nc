/**
 * Implementation of node's configuration management.
 * 
 * This module offers functionality to set and get the node's
 * configuration over an AM channel.
 * 
 *  @version   0.1
 * 	@date      2012-2013
 */

#include "printf.h"
#include "ProtectLayerGlobals.h"
module ConfigurationP {
	uses {
		interface SplitControl as SerialControl;

		interface AMSend as ConfSDSend;
                interface AMSend as ConfSDPartSend;
		interface AMSend as ConfPPCPDSend;
		interface AMSend as ConfRPDSend;
		interface AMSend as ConfKDCPDSend;
		interface Receive as ConfGet;
		interface Receive as ConfSDGet;
                interface Receive as ConfSDPartGet;
		interface Receive as ConfPPCPDGet;
		interface Receive as ConfRPDGet;
		interface Receive as ConfKDCPDGet;
		interface Packet as PacketSD;
                interface Packet as PacketSDPart;
		interface Packet as PacketPPCPD;
		interface Packet as PacketRPD;
		interface Packet as PacketKDCPD;
		interface AMPacket;
		interface PacketAcknowledgements as Acks;

		interface Leds;
		interface SharedData;

		interface Queue<message_t>;
	}
	provides {
		interface Init;
		interface Configuration;
	}
}

implementation {
	/** flag signaling whether the serial port is busy */ 
	bool serialBusy;
	/** packet for responses */
	message_t packet;
	/** send messages counter */
	uint16_t msgCounter = 0;
	/** counter of the savedData messages */
	uint8_t counterSD = 0;
        /** counter for partional sd messages */
        uint8_t partSD = 0;
	
	task void sendSDMessageTask();
        task void sendSDPartMessageTask();
	task void sendPPCPDMessageTask();
	task void sendRPDMessageTask();
	task void sendKDCPDMessageTask();

	/** 
	 * Start the radio and serial ports when booting 
	 */
	command error_t Init.init() {
		if(call SerialControl.start() != SUCCESS) 
			return FAIL;
                
		return SUCCESS;
	}

	/** 
     * Notify caller that the component has been started and is ready to
     * receive other commands.
     *
     * @param <b>error</b> -- SUCCESS if the component was successfully
     *                        turned on, FAIL otherwise
     */
	event void SerialControl.startDone(error_t error) {
		if(error != SUCCESS) {
			call Leds.led0On();
			call Leds.led1On();
		}
	}

	/**
     * Notify caller that the component has been stopped.
     *
     * @param <b>error</b> -- SUCCESS if the component was successfully
     *                        turned off, FAIL otherwise
     */
	event void SerialControl.stopDone(error_t error) {
	}

	/**
	 * Saves the incoming settings for neighboring node to the SharedData module.
	 * 
	 * @param msg Expects a translated SavedDataMsg
	 * @param  'void* COUNT(len) payload'  a pointer to the packet's payload
	 * @param  len      the length of the data region pointed to by payload
	 * @return the incoming message msg 
	 */
	event message_t * ConfSDGet.receive(message_t * msg, void * payload,
			uint8_t len) {

		if(len == sizeof(con_sd_msg_t)) {
			con_sd_msg_t * csd = (con_sd_msg_t * ) payload;
			(call SharedData.getAllData())->savedData[csd->savedDataIdx] = csd->savedData;
		}
		return msg;
	}

        event message_t * ConfSDPartGet.receive(message_t * msg, void * payload, uint8_t len){
                con_sd_part_msg_t * csd = (con_sd_part_msg_t * ) payload;
                uint8_t i = 0;
                uint16_t tmp = 0;

                switch (csd->key){
                        case SD_KEY_TYPE: //nx_uint8_t
                                (call SharedData.getAllData())->savedData->kdcData.shared_key.keyType = csd->data[0];
                                break;

                        case SD_KEY_VALUE: //KEY_LENGTH * nx_uint8_t
                                for(i = 0; i < KEY_LENGTH && i < csd->len; i++){
                                        (call SharedData.getAllData())->savedData->kdcData.shared_key.keyValue[i] = csd->data[i];
                                }
                                break;

                        case SD_DBG_KEY_ID: //nx_uint16_t
                                tmp |= csd->data[0];
                                tmp = tmp << 8;
                                tmp |= csd->data[1];
  
                                (call SharedData.getAllData())->savedData->kdcData.shared_key.dbgKeyID = tmp;

                                break;

                        case SD_COUNTER: //nx_uint8_t
                                (call SharedData.getAllData())->savedData->kdcData.counter = csd->data[0];
                                break;
    
                        case SD_REPUTATION: //nx_uint8_t
                                (call SharedData.getAllData())->savedData->idsData.neighbor_reputation = csd->data[0];
                                break;

                        case SD_NB_MESSAGES: //nx_uint8_t
                                (call SharedData.getAllData())->savedData->idsData.nb_messages = csd->data[0];
                                break;

                        default:
                                break;

                        /*default:
                                partSD = 0;
                                return msg;*/

                }
                return msg;
        }

	/**
	 * Saves the incoming settings for this node's privacy protection module
	 * to the SharedData module.
	 * 
	 * @param msg Expects a translated PPCPrivDataMsg
	 * @param  'void* COUNT(len) payload'  a pointer to the packet's payload
	 * @param  len      the length of the data region pointed to by payload
	 * @return the incoming message msg 
	 */
	event message_t * ConfPPCPDGet.receive(message_t * msg, void * payload,
			uint8_t len) {
		if(len == sizeof(con_ppcpd_msg_t)) {
			con_ppcpd_msg_t * ppcm = (con_ppcpd_msg_t * ) payload;
			(call SharedData.getAllData())->ppcPrivData = ppcm->ppcPrivData;
		}
		return msg;
	}
	
	event message_t * ConfRPDGet.receive(message_t * msg, void * payload,
			uint8_t len) {
		if(len == sizeof(con_rpd_msg_t)) {
			con_rpd_msg_t * rm = (con_rpd_msg_t * ) payload;
			(call SharedData.getAllData())->routePrivData = rm->rPrivData;
		}
		return msg;
	}
	
	event message_t * ConfKDCPDGet.receive(message_t *msg, void *payload, uint8_t len){
		if(len == sizeof(con_kdcpd_msg_t)) {
			con_kdcpd_msg_t * kdcm = (con_kdcpd_msg_t * ) payload;
			(call SharedData.getAllData())->kdcPrivData = kdcm->kdcPrivData;
		}
		return msg;
	}
	
	/**
	 * Sends all the currently saved settings in SharedData module to the pc 
	 * via task sendSDMessageTask that calls task sendPPCPDMessageTask afterwards.
	 * 
	 * @param msg Expects a translated GetConfMsg
	 * @param  'void* COUNT(len) payload'  a pointer to the packet's payload
	 * @param  len      the length of the data region pointed to by payload
	 * @return the incoming message msg 
	 */
	event message_t * ConfGet.receive(message_t * msg, void * payload,
			uint8_t len) {
		if(len == sizeof(con_get_msg_t)) {
			//post sendSDMessageTask();
                        post sendSDPartMessageTask();
		}
		return msg;
	}
	
	/**
	 * Event that makes is responsible for sending ALL the data. 
	 * That is after sending all the savedData it sends also the privacy
	 * module's data and so on.
	 * 
	 * @param  'message_t* ONE msg'   the packet which was submitted as a send request
     * @param  error SUCCESS if it was sent successfully, FAIL if it was not,
     *               ECANCEL if it was cancelled
	 */
	event void ConfSDSend.sendDone(message_t * msg, error_t error) {
		serialBusy = FALSE;
		if (error == SUCCESS) {
			if (++counterSD < MAX_NEIGHBOR_COUNT) {			
				post sendSDMessageTask();
			} else {
				counterSD = 0;
				post sendPPCPDMessageTask();
			}			
		} else {
			counterSD = 0;			
		}
	}

        event void ConfSDPartSend.sendDone(message_t * msg, error_t error){
                serialBusy = FALSE;
                if(error == SUCCESS){
                        post sendSDPartMessageTask();
                }
                else {
                        partSD = 0;
                }
        }

	/**
	 * A final event that releases the serialBusy flag
	 * 
	 * @param  'message_t* ONE msg'   the packet which was submitted as a send request
     * @param  error SUCCESS if it was sent successfully, FAIL if it was not,
     *               ECANCEL if it was cancelled
	 */
	event void ConfPPCPDSend.sendDone(message_t * msg, error_t error) {
		serialBusy = FALSE;
		if(error == SUCCESS) {
			post sendRPDMessageTask();
		}
	}
	
	event void ConfRPDSend.sendDone(message_t *msg, error_t error){
		serialBusy = FALSE;
		if(error == SUCCESS) {
			post sendKDCPDMessageTask();
		}
	}

	event void ConfKDCPDSend.sendDone(message_t *msg, error_t error){
		serialBusy = FALSE;
	}

	/**
	 * Implementation of the Configuration interface signalling method
	 */
	command error_t Configuration.signalConfSend() {
		if (serialBusy == FALSE) {
			signal ConfGet.receive(&packet, NULL, sizeof(con_get_msg_t));
			return SUCCESS;
		}
		return EBUSY;
	}
	
	/**
	 * A task to send a neighboring node's stored data from SharedData module
	 * to the pc.
	 */
	task void sendSDMessageTask() {
		if(! serialBusy) {
			//TODO data are too big for this packet
			con_sd_msg_t * csm = (con_sd_msg_t * ) call PacketSD.getPayload(&packet,
					sizeof(con_sd_msg_t));

			if(csm == NULL) {
				counterSD = 0;
				return;
			}
			if(call PacketSD.maxPayloadLength() < sizeof(con_sd_msg_t)) {
				counterSD = 0;
				return;
			}
			csm->counter = msgCounter++;
			csm->savedDataIdx = counterSD;
			csm->savedData = (call SharedData.getSavedData())[counterSD];
			if(call ConfSDSend.send(AM_BROADCAST_ADDR, &packet,
					(uint8_t) sizeof(con_sd_msg_t)) == SUCCESS) {
				serialBusy = TRUE;
			}
		}
	}


        task void sendSDPartMessageTask(){
                uint16_t tmp;

                con_sd_part_msg_t * csm = (con_sd_part_msg_t *) call PacketSDPart.getPayload(&packet, sizeof(con_sd_part_msg_t));

                if(NULL == csm){
                        partSD = 0;
                        return;
                }

                switch ((uint8_t)partSD){
                        case 0:
                        case SD_KEY_TYPE:  //nx_uint8_t
                                csm->len = 1;
                                csm->key = SD_KEY_TYPE;
                                csm->data[0] = (call SharedData.getAllData())->savedData->kdcData.shared_key.keyType;

                                partSD = SD_KEY_VALUE;
                                break;

                        case SD_KEY_VALUE: //KEY_LENGTH * nx_uint8_t
                                csm->len = KEY_LENGTH;
                                csm->key = SD_KEY_VALUE;
                                for(tmp = 0; tmp < KEY_LENGTH; tmp++){
                                        csm->data[tmp] = (call SharedData.getAllData())->savedData->kdcData.shared_key.keyValue[tmp];
                                }
                                partSD = SD_DBG_KEY_ID;
                                break;

                        case SD_DBG_KEY_ID: //nx_uint16_t
                                tmp = (call SharedData.getAllData())->savedData->kdcData.shared_key.dbgKeyID;

                                csm->len = 2;
                                csm->key = SD_DBG_KEY_ID;

                                csm->data[1] = 0 | tmp;
                                csm->data[0] = 0 | (tmp >> 8);

                                partSD = SD_COUNTER;
                                break;

                        case SD_COUNTER: //nx_uint8_t
                                csm->len = 1;
                                csm->key = SD_COUNTER;
                                csm->data[0] = (call SharedData.getAllData())->savedData->kdcData.counter;
                                partSD = SD_REPUTATION;
                                break;
    
                        case SD_REPUTATION: //nx_uint8_t
                                csm->len = 1;
                                csm->key = SD_REPUTATION;
                                csm->data[0] = (call SharedData.getAllData())->savedData->idsData.neighbor_reputation;
                                partSD = SD_NB_MESSAGES;
                                break;

                        case SD_NB_MESSAGES: //nx_uint8_t
                                csm->len = 1;
                                csm->key = SD_NB_MESSAGES;
                                csm->data[0] = (call SharedData.getAllData())->savedData->idsData.nb_messages;
                        default:
                                partSD = 0;
                                break;
                }

                if(partSD != 0 && call ConfSDPartSend.send(AM_BROADCAST_ADDR, &packet, (uint8_t) sizeof(con_sd_part_msg_t)) == SUCCESS) {
                        serialBusy = TRUE;
                }
        }
	
	/**
	 * A task to send local privacy module's stored data from SharedData module
	 * to the pc.
	 */
	task void sendPPCPDMessageTask() {
		if(! serialBusy) {
			//TODO data are too big for this packet
			con_ppcpd_msg_t * ppcm = (con_ppcpd_msg_t * ) call PacketPPCPD.getPayload(&packet,
					sizeof(con_ppcpd_msg_t));

			if(ppcm == NULL) {
				return;
			}
			if(call PacketPPCPD.maxPayloadLength() < sizeof(con_ppcpd_msg_t)) {
				return;
			}
			ppcm->counter = msgCounter++;
			ppcm->ppcPrivData = *call SharedData.getPPCPrivData();
			if(call ConfPPCPDSend.send(AM_BROADCAST_ADDR, &packet,
					(uint8_t) sizeof(con_ppcpd_msg_t)) == SUCCESS) {
				serialBusy = TRUE;
			}
		}
	}
	
	task void sendRPDMessageTask() {
		if(! serialBusy) {
			//TODO data are too big for this packet
			con_rpd_msg_t * rm = (con_rpd_msg_t * ) call PacketRPD.getPayload(&packet,
					sizeof(con_rpd_msg_t));

			if(rm == NULL) {
				return;
			}
			if(call PacketRPD.maxPayloadLength() < sizeof(con_rpd_msg_t)) {
				return;
			}
			rm->counter = msgCounter++;
			rm->rPrivData = *call SharedData.getRPrivData();
			if(call ConfRPDSend.send(AM_BROADCAST_ADDR, &packet,
					(uint8_t) sizeof(con_rpd_msg_t)) == SUCCESS) {
				serialBusy = TRUE;
			}
		}
	}

	task void sendKDCPDMessageTask() {
		if(! serialBusy) {
			//TODO data are too big for this packet
			con_kdcpd_msg_t * kdcm = (con_kdcpd_msg_t * ) call PacketKDCPD.getPayload(&packet,
					sizeof(con_kdcpd_msg_t));

			if(kdcm == NULL) {
				return;
			}
			if(call PacketKDCPD.maxPayloadLength() < sizeof(con_kdcpd_msg_t)) {
				return;
			}
			kdcm->counter = msgCounter++;
			kdcm->kdcPrivData = *call SharedData.getKDCPrivData();
			if(call ConfKDCPDSend.send(AM_BROADCAST_ADDR, &packet,
					(uint8_t) sizeof(con_kdcpd_msg_t)) == SUCCESS) {
				serialBusy = TRUE;
			}
		}
	}
}

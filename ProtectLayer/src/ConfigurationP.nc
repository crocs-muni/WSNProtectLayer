/**
 * Implementation of node's configuration management.
 * 
 * This module offers functionality to set and get the node's
 * configuration over an AM channel.
 * 
 *  @version   1.0
 * 	@date      2012-2014
 */

#include "ProtectLayerGlobals.h"
module ConfigurationP {
	uses {
		interface SplitControl as SerialControl;

		interface AMSend as ConfSDSend;
		interface AMSend as ConfPPCPDSend;
		interface AMSend as ConfRPDSend;
		interface AMSend as ConfKDCPDSend;
		interface Receive as ConfGet;
		interface Receive as ConfSDGet;
		interface Receive as ConfPPCPDGet;
		interface Receive as ConfRPDGet;
		interface Receive as ConfKDCPDGet;
		interface Packet as PacketSD;
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
	
	task void sendSDMessageTask();
	task void sendPPCPDMessageTask();
	task void sendRPDMessageTask();
	task void sendKDCPDMessageTask();

	/** 
	 * Start the radio and serial ports when booting 
	 */
	command error_t Init.init() {
		// if necessary do anything here, discuss with Jiri or PetrS
		//if(call SerialControl.start() != SUCCESS) 
		//	return FAIL;
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
	
	/**
	 * Saves the incoming settings for this node's routing module
	 * to the SharedData module.
	 * 
	 * @param msg Expects a translated RPDPrivDataMsg
	 * @param  'void* COUNT(len) payload'  a pointer to the packet's payload
	 * @param  len      the length of the data region pointed to by payload
	 * @return the incoming message msg 
	 */
	event message_t * ConfRPDGet.receive(message_t * msg, void * payload,
			uint8_t len) {
		if(len == sizeof(con_rpd_msg_t)) {
			con_rpd_msg_t * rm = (con_rpd_msg_t * ) payload;
			(call SharedData.getAllData())->routePrivData = rm->rPrivData;
		}
		return msg;
	}
	
	/**
	 * Saves the incoming settings for this node's key distribution module
	 * to the SharedData module.
	 * 
	 * @param msg Expects a translated KDCPrivDataMsg
	 * @param  'void* COUNT(len) payload'  a pointer to the packet's payload
	 * @param  len      the length of the data region pointed to by payload
	 * @return the incoming message msg 
	 */
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
			post sendSDMessageTask();
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

	/**
	 * A final event that releases the serialBusy flag.
	 * Continue sending the requested data by posting appropriate task.
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
	
	/**
	 * A final event that releases the serialBusy flag.
	 * Continue sending the requested data by posting appropriate task.
	 * 
	 * @param  'message_t* ONE msg'   the packet which was submitted as a send request
     * @param  error SUCCESS if it was sent successfully, FAIL if it was not,
     *               ECANCEL if it was cancelled
	 */
	event void ConfRPDSend.sendDone(message_t *msg, error_t error){
		serialBusy = FALSE;
		if(error == SUCCESS) {
			post sendKDCPDMessageTask();
		}
	}

	/**
	 * A final event that releases the serialBusy flag.
	 * 
	 * @param  'message_t* ONE msg'   the packet which was submitted as a send request
     * @param  error SUCCESS if it was sent successfully, FAIL if it was not,
     *               ECANCEL if it was cancelled
	 */
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
	
	/**
	 * A task to send local routing module's stored data from SharedData module
	 * to the pc.
	 */
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

	/**
	 * A task to send local key distribution module's stored data from SharedData module
	 * to the pc.
	 */
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

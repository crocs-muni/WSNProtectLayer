/**
 * Module for logging short messages.
 * 
 * 	@version   0.1
 * 	@date      2012-2013
 */

#include "printf.h"

module LoggerP {
	provides {
		interface Logger;
		interface Init;
	}
	uses {
		interface SplitControl as SerialControl;
		
		interface AMSend as LowerAMSend;
	    interface Packet;
	    interface AMPacket;
	    interface PacketAcknowledgements as Acks;
	    
	    interface Receive;
	    
	    interface Leds;
	    
	    #ifndef TOSSIM	
		interface BlockRead;
		interface BlockWrite;	
		#endif
	}
}

implementation {
	/** flag signaling whether the serial port is busy */ 
	bool serialBusy;
	/** flag signaling whether the memory is busy */
	bool memoryBusy;
	/** packet for responses */
	message_t packet;
	/** send messages counter */
	uint16_t msgCounter = 0;
	/** current offset in the memory */
	storage_addr_t offset = 0;
	/** required length of block read from the memory at a time */
	uint8_t blockLength = 0;
	
	bool readDone = FALSE;
	
	task void sendLogMemoryTask();
	
	/**
	 * Start the serial ports when booting 
	 */
	command error_t Init.init(){
   		
   		//if (call SerialControl.start() != SUCCESS)
   		//	return FAIL;
   		
   		//TODO zmenit na pouze nahrani aplikace?
   		/*   		
   		memoryBusy = TRUE;
   		if (call BlockWrite.erase() != SUCCESS)
   			return FAIL;
   		
   		return SUCCESS;
                */
        return SUCCESS;
  	}
  	
  	/** 
     * Notify caller that the component has been started and is ready to
     * receive other commands.
     *
     * @param <b>error</b> -- SUCCESS if the component was successfully
     *                        turned on, FAIL otherwise
     */
  	event void SerialControl.startDone(error_t error){
		if (error != SUCCESS) {
			call Leds.led1On();
			call Leds.led2On();
		}  		
  	}
  	
  	/**
     * Notify caller that the component has been stopped.
     *
     * @param <b>error</b> -- SUCCESS if the component was successfully
     *                        turned off, FAIL otherwise
     */
  	event void SerialControl.stopDone(error_t error) { }
	
	/**
	 * Command to forward the log message to the next layer.
	 * 
	 * @param msg the message to be logged to the PC via serial
	 * @return SUCCESS if the transmission was successfull, ESIZE if the message is larger than TOSH_DATA_SIZE, FAIL otherwise
	 */
	command error_t Logger.logToPC(message_t *msg, uint8_t len){
		//call Leds.led0On();
    	if (!serialBusy)
      	{	
			if (msg != NULL) {			
				serialBusy = TRUE;
	  			return call LowerAMSend.send(AM_BROADCAST_ADDR, msg, len);	  			
			}
			return FAIL;
      	}
      	return EBUSY;
	}
	
	/**
	 * A task to send a neighboring node's stored data from the flash to the pc.
	 */
	task void sendLogMemoryTask() {
		log_msg_t* logMsg = (log_msg_t*)call Packet.getPayload(&packet, sizeof(log_msg_t));
		if (!memoryBusy) {
			logMsg->counter = ++msgCounter; 
			logMsg->blockLength = blockLength;
			memoryBusy = TRUE;
			call BlockRead.read(offset, logMsg->data, 
			(blockLength < call BlockRead.getSize() - offset) ? blockLength : (call BlockRead.getSize() - offset));
		}	
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		if(len == sizeof(log_msg_t)) {
			log_msg_t * incMsg = (log_msg_t * ) payload;
						
			if (incMsg->blockLength <= LOGGED_SIZE) {
				//call Leds.led2On();
				msgCounter = incMsg->counter;
				offset = 0;
				blockLength = incMsg->blockLength;

				post sendLogMemoryTask();
			}
		}
		return msg;
	}

	/** 
     * Signaled in response to an accepted send request. <tt>msg</tt> is
     * the message buffer sent, and <tt>error</tt> indicates whether
     * the send was successful.
     *
     * @param  'message_t* ONE msg'   the packet which was submitted as a send request
     * @param  error SUCCESS if it was sent successfully, FAIL if it was not,
     *               ECANCEL if it was cancelled
     */
	event void LowerAMSend.sendDone(message_t *msg, error_t error){
		serialBusy = FALSE;
		if (offset > 0) {
			if (!readDone && offset < call BlockRead.getSize()) {
				post sendLogMemoryTask();
			} else {
				readDone = FALSE;
				offset = 0;
			}		
		} else {
      		signal Logger.logToPCDone(msg, error);
      	}
	}
	
	event void BlockRead.readDone(storage_addr_t addr, void *buf, storage_len_t len, error_t error){
		memoryBusy = FALSE;
		if (error == SUCCESS) {
			int i;
			nx_uint8_t * data = (nx_uint8_t * ) buf;
			for (i = 0; i < len; i++) {
				if (data[i] == 0xff) {
					readDone = TRUE;						
				} else {
					readDone = FALSE;
					break;
				}				
			}	
			if (!serialBusy) {
				offset += len;
				serialBusy = TRUE;
				call LowerAMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(log_msg_t));				
			}
		} else {
			call Leds.set(LEDS_LED0 | LEDS_LED1 | LEDS_LED2);
		}
	}

	event void BlockRead.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error){
		// TODO Auto-generated method stub
	}
	
	event void BlockWrite.writeDone(storage_addr_t addr, void *buf, storage_len_t len, error_t error){
		// TODO Auto-generated method stub
	}

	event void BlockWrite.eraseDone(error_t error){
		memoryBusy = FALSE;
	}

	event void BlockWrite.syncDone(error_t error){
		// TODO Auto-generated method stub
	}
}

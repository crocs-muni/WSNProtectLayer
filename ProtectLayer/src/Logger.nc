/**
 * Basic interface for logging.
 * 
 * 	@version   1.0
 * 	@date      2012-2014
 */

#include "ProtectLayerGlobals.h"
interface Logger {
	/**
	 * Command to forward the log message to the next layer.
	 * 
	 * @param msg the message to be logged to the PC via serial
	 * @param len length of the message to send
	 */
	command error_t logToPC(message_t* msg, uint8_t len);
	
	/** 
     * Signaled in response to an accepted logToPC request. <tt>msg</tt> is
     * the message buffer sent, and <tt>error</tt> indicates whether
     * the send was successful.
     *
     * @param  'message_t* ONE msg'   the packet which was submitted as a send request
     * @param  error SUCCESS if it was sent successfully, FAIL if it was not,
     *               ECANCEL if it was cancelled
	 */
	event void logToPCDone(message_t* msg, error_t error);
}

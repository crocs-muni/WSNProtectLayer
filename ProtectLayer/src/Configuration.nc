/**
 * Interface for enabling Configuration component signalling over the application
 * 
 * @author Filip Jurnecka
 */
#include "printf.h"
#include "ProtectLayerGlobals.h"
interface Configuration {
	/**
	 * Support method for signalling incoming message
	 * 
	 * @return a pointer to the combinedData structure
	 */
	command error_t signalConfSend();
	
	/** 
     * Signaled in response to an accepted signalConfSend request. <tt>error</tt> indicates whether
     * the send was successful.
     *
     * @param  error SUCCESS if it was signalled successfully
     *               EBUSY if the serial is busy
	 */
	event void signalConfSendDone(error_t error);	
}
/**
 *
 * Interface Dispatcher provides commands for dispatcher management. 
 * 	@version   1.0
 * 	@date      2012-2014
 */




#include "ProtectLayerGlobals.h"
interface Dispatcher{
	/**
	 * Executes transition to the next state based on internal variables values.
	 */
	command void serveState();
	
	/**
	 * Informs the dispatcher about finished execution of <em>finishedState</em>
	 * 
	 * @param finishedState the state identifier
	 */
	command void stateFinished(uint8_t finishedState);
	
#ifdef THIS_IS_BS
	/**
	 * Signals imminent transition to a <em>newState</em>
	 * Only used for signaling in base station
	 * 
	 * @param newState the new state identifier
	 */
	event void stateChanged(uint8_t newState);
#endif
}
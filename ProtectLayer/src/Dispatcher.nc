/**
 *
 * Interface Dispatcher provides commands for dispatcher management. 
 * 	@version   0.1
 * 	@date      2012-2013
 */




#include "ProtectLayerGlobals.h"
interface Dispatcher{
	
	command void serveState();
	
	command void stateFinished(uint8_t finishedState);
	
#ifdef THIS_IS_BS
	event void stateChanged(uint8_t newState);
#endif
}
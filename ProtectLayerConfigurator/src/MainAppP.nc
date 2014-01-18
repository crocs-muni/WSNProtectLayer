#include "ProtectLayerGlobals.h"

module MainAppP {
	uses interface Boot;
	//uses interface Configuration;
	uses interface Init;
}
implementation {
	event void Boot.booted(){
		call Init.init();	
	}

	//event void Configuration.signalConfSendDone(error_t error){
	//
	//}
}

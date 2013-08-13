#include "../../ProtectLayer/src/ProtectLayerGlobals.h"
//#include "printf.h" 
module IntruderAppP {
    uses {
    	interface Boot;
    	interface Init;
    }
}
implementation {

	event void Boot.booted() {
		call Init.init();
	} 
}

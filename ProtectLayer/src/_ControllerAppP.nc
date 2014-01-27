#include "ProtectLayerGlobals.h"
#include "printf.h" 
module ControllerAppP {
    uses {
    	interface Boot;
    	interface Init;
    }
}
implementation {

	event void Boot.booted() {
		//printf("ControllerAppP.Boot.booted() entered"); printfflush(); printfflush();
		// TODO: may initilialize additional components, that are now wired to Boot.SoftwareInit
		//call PPC.init();
		//call IDS.init();
		//call KDC.init();
		//call App1.init();
		//call Logger.init();
		call Init.init();
	} 
}

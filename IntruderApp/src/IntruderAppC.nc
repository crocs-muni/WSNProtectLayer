#include "../../ProtectLayer/src/ProtectLayerGlobals.h"
configuration IntruderAppC {}
implementation {
	components MainC, IntruderAppP, IntruderC;   
  
  	IntruderAppP.Boot -> MainC.Boot;
	IntruderAppP.Init -> IntruderC.Init;
}

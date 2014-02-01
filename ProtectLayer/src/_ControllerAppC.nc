#include "ProtectLayerGlobals.h"

configuration ControllerAppC {}
implementation {
	components MainC, ControllerAppP, ProtectLayerC, UserApp1C, ConfigurationC, TestFlashC, LoggerC;   
  
  	ControllerAppP.Boot -> MainC.Boot;
	ControllerAppP.Init -> TestFlashC.Init;
	MainC.SoftwareInit -> ProtectLayerC.Init;	// auto-initialization
	MainC.SoftwareInit -> UserApp1C.Init;	// auto-initialization
}

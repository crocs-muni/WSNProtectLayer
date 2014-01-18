#include "ProtectLayerGlobals.h"

configuration MainAppC {
}
implementation {
	components MainC, ConfigurationC, MainAppP as Main;

	Main.Boot -> MainC.Boot;
	Main.Init -> ConfigurationC.Init;
	//Main.Configuration -> ConfigurationC.Configuration;
}

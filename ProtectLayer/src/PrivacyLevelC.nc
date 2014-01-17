/**
 * Abstraction of privacy level component.
 * Configuration acts as a front-end for the PrivacyLevelP component. 
 * All components using PrivacyLevelP should wire to this configuration not directly to the PrivacyLevelP.
 * The configuration is used to wire the PrivacyLevelP to other components (interface providers).
 * 	@version   0.1
 * 	@date      2012-2013 
 **/

#include "ProtectLayerGlobals.h"
configuration PrivacyLevelC{
	provides {
		interface Init;
		interface PrivacyLevel;		
		}
}
implementation{
	components PrivacyC;
	components CryptoC;
	components PrivacyLevelP;
    components DispatcherC;
    components new TimerMilliC() as TimerPL; //testing
	
	PrivacyLevelP.TimerP-> TimerPL; //testing
	
	PrivacyLevelP.Privacy->PrivacyC.Privacy;
	PrivacyLevel = PrivacyLevelP.PrivacyLevel;
	Init = PrivacyLevelP.Init;
	
		
	PrivacyLevelP.AMSend -> PrivacyC.MessageSend[MSG_PLEVEL];
	PrivacyLevelP.Receive -> DispatcherC.ChangePL_Receive;
	
	PrivacyLevelP.Crypto -> CryptoC.Crypto;
	

	
	
	
}

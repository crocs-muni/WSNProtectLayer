/**
 * Abstraction of privacy level component.
 * Configuration acts as a front-end for the PrivacyLevelP component. 
 * All components using PrivacyLevelP should wire to this configuration not directly to the PrivacyLevelP.
 * The configuration is used to wire the PrivacyLevelP to other components (interface providers).
 * 	@version   1.0
 * 	@date      2012-2014
 **/

#include "ProtectLayerGlobals.h"
configuration PrivacyLevelC{
	provides {
		interface PrivacyLevel;
		interface MagicPacket;		
		interface Init;
		}
}
implementation{
	components MainC;
	components PrivacyLevelP;
#ifndef THIS_IS_BS	
	components PrivacyC;
	components CryptoC;
    components DispatcherC;
    components SharedDataC;
    components RandomC;
    components new TimerMilliC() as BackoffTimer;
    components new AMSenderC(AM_CHANGEPL) as AMSender;
#endif
	
	MainC.SoftwareInit -> PrivacyLevelP.Init; // auto init phase 1
	PrivacyLevel = PrivacyLevelP.PrivacyLevel;
	Init = PrivacyLevelP.PLInit;
	MagicPacket = PrivacyLevelP.MagicPacket;
	
#ifndef THIS_IS_BS	
	PrivacyLevelP.Privacy->PrivacyC.Privacy;	
	PrivacyLevelP.AMSend -> AMSender;
	PrivacyLevelP.Receive -> DispatcherC.ChangePL_Receive;
	PrivacyLevelP.SharedData -> SharedDataC.SharedData;
	PrivacyLevelP.Crypto -> CryptoC.Crypto;
	PrivacyLevelP.BackoffTimer -> BackoffTimer;
	PrivacyLevelP.Random ->RandomC;
#endif
}

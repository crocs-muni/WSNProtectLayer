/** 
 *  Abstraction for DispatcherP component.
 *  @version   1.0
 * 	@date      2012-2014
 */

#include "ProtectLayerGlobals.h"

configuration DispatcherC{
	provides {
		interface Receive as PL_Receive;
		interface Receive as IDS_Receive;
		interface Receive as ChangePL_Receive;
		interface Receive as Sniff_Receive;
		interface Dispatcher;
	}
}
implementation{
	components DispatcherP;
	components ActiveMessageC;   
	components MainC;
	components CryptoC;
	components PrivacyC;
	components RouteC;
	components SharedDataC;
	components PrivacyLevelC;
	components IntrusionDetectC;
	components KeyDistribC;
	components new TimerMilliC() as BackupCombinedDataTimer;
	
#ifndef THIS_IS_BS	
	components new AMReceiverC(AM_PROTECTLAYERRADIO) as PL_ReceiverC;
	components new AMReceiverC(AM_CHANGEPL) as ChangePL_ReceiverC;
	components new AMReceiverC(AM_IDS_ALERT) as IDS_ReceiverC;
#endif

	MainC.SoftwareInit -> DispatcherP.Init;
	
#ifndef THIS_IS_BS	
	DispatcherP.Lower_PL_Receive -> PL_ReceiverC;
	DispatcherP.Lower_IDS_Receive -> IDS_ReceiverC;
	DispatcherP.Lower_ChangePL_Receive -> ChangePL_ReceiverC;
#endif

	DispatcherP.Packet -> ActiveMessageC.Packet;
	
	PL_Receive = DispatcherP.PL_Receive;
	IDS_Receive = DispatcherP.IDS_Receive;
	ChangePL_Receive = DispatcherP.ChangePL_Receive;
	Sniff_Receive = DispatcherP.Sniff_Receive;
	
	
	
	//DispatcherP.CryptoCInit -> CryptoC.Init;
	DispatcherP.PrivacyCInit -> PrivacyC.PLInit;
	DispatcherP.SharedDataCInit -> SharedDataC.PLInit;
	DispatcherP.IntrusionDetectCInit -> IntrusionDetectC.PLInit;
	DispatcherP.KeyDistribCInit -> KeyDistribC.Init;
	DispatcherP.PrivacyLevelCInit -> PrivacyLevelC.Init;
	DispatcherP.RouteCInit -> RouteC.PLInit;
	DispatcherP.Privacy -> PrivacyC.Privacy;
	DispatcherP.MagicPacket -> PrivacyLevelC.MagicPacket;
	//DispatcherP.ForwarderCInit -> ForwarderC.Init;
	//DispatcherP.PrivacyLevelCInit -> PrivacyLevelC.Init;
	DispatcherP.ResourceArbiter -> SharedDataC.ResourceArbiter;
	DispatcherP.SharedData -> SharedDataC.SharedData;
	DispatcherP.BackupCombinedDataTimer -> BackupCombinedDataTimer;
	
	Dispatcher = DispatcherP.Dispatcher;
}

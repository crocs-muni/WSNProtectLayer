
#include "ProtectLayerGlobals.h"

configuration DispatcherC{
	provides {
		interface Receive as PL_Receive;
		interface Receive as IDS_Receive;
		interface Receive as ChangePL_Receive;
	}
}
implementation{
	components DispatcherP;
	components ActiveMessageC;   
	components MainC;
	components CryptoC;
	components PrivacyC;
	components SharedDataC;
	components ForwarderC;
	components PrivacyLevelC;
	
	components new AMReceiverC(AM_PROTECTLAYERRADIO) as PL_ReceiverC;
	components new AMReceiverC(AM_CHANGEPL) as ChangePL_ReceiverC;
	components new AMReceiverC(AM_IDS_ALERT) as IDS_ReceiverC;
	
	MainC.SoftwareInit -> DispatcherP.Init;
	
	DispatcherP.Lower_PL_Receive -> PL_ReceiverC;
	DispatcherP.Lower_IDS_Receive -> IDS_ReceiverC;
	DispatcherP.Lower_ChangePL_Receive -> ChangePL_ReceiverC;
	
	DispatcherP.Packet -> ActiveMessageC.Packet;
	
	PL_Receive = DispatcherP.PL_Receive;
	IDS_Receive = DispatcherP.IDS_Receive;
	ChangePL_Receive = DispatcherP.ChangePL_Receive;
	
	
	
	
	DispatcherP.CryptoCInit -> CryptoC.Init;
	DispatcherP.PrivacyCInit -> PrivacyC.Init;
	DispatcherP.SharedDataCInit -> SharedDataC.Init;
	DispatcherP.ForwarderCInit -> ForwarderC.Init;
	DispatcherP.PrivacyLevelCInit -> PrivacyLevelC.Init;
}

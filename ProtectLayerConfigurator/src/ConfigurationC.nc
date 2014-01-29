/**
 * Setting of the Configuration module to SerialAM (USB).
 * 
 * 	@version   0.1
 * 	@date      2012-2013
 */
#include "printf.h"
#include "ProtectLayerGlobals.h"
configuration ConfigurationC{
	provides {
		interface Init;
		interface Configuration;
	}
}

implementation{
	components ConfigurationP;
	components new SerialAMSenderC(AM_CON_SD_MSG) as ConfSDSend;
        components new SerialAMSenderC(AM_CON_SD_PART_MSG) as ConfSDPartSend;
	components new SerialAMSenderC(AM_CON_PPCPD_MSG) as ConfPPCPDSend;
	components new SerialAMSenderC(AM_CON_RPD_MSG) as ConfRPDSend;
	components new SerialAMSenderC(AM_CON_KDCPD_MSG) as ConfKDCPDSend;
	components new SerialAMSenderC(AM_KEY_MSG) as ConfKeySend;
	
	components new SerialAMReceiverC(AM_CON_GET_MSG) as ConfGet;
	components new SerialAMReceiverC(AM_CON_SD_MSG) as ConfSDGet;
        components new SerialAMReceiverC(AM_CON_SD_PART_MSG) as ConfSDPartGet;
	components new SerialAMReceiverC(AM_CON_PPCPD_MSG) as ConfPPCPDGet;
	components new SerialAMReceiverC(AM_CON_RPD_MSG) as ConfRPDGet;
	components new SerialAMReceiverC(AM_CON_KDCPD_MSG) as ConfKDCPDGet;
	
	components new SerialAMReceiverC(AM_KEY_MSG) as ConfKeyGet;
	
	components SerialActiveMessageC;
	components SharedDataC;
	components LedsC;
	//queue for the entire combined data
	components new QueueC(message_t, MAX_NEIGHBOR_COUNT + 3);
	components MainC;
		
	Init = ConfigurationP.Init;
	
	ConfigurationP.ConfSDSend -> ConfSDSend;
        ConfigurationP.ConfSDPartSend -> ConfSDPartSend;
	ConfigurationP.PacketSD -> ConfSDSend;
        ConfigurationP.PacketSDPart -> ConfSDPartSend;
	ConfigurationP.AMPacket -> ConfSDSend;
	ConfigurationP.Acks -> ConfSDSend;
	
	ConfigurationP.ConfPPCPDSend -> ConfPPCPDSend;
	ConfigurationP.ConfRPDSend -> ConfRPDSend;
	ConfigurationP.ConfKDCPDSend -> ConfKDCPDSend;
	ConfigurationP.ConfKeySend -> ConfKeySend;
	
	ConfigurationP.PacketPPCPD -> ConfPPCPDSend;
	ConfigurationP.PacketRPD -> ConfRPDSend;
	ConfigurationP.PacketKDCPD -> ConfKDCPDSend;
	ConfigurationP.PacketKey -> ConfKeySend;
	
	ConfigurationP.ConfGet -> ConfGet;
	ConfigurationP.ConfSDGet -> ConfSDGet;
        ConfigurationP.ConfSDPartGet -> ConfSDPartGet;
	ConfigurationP.ConfPPCPDGet -> ConfPPCPDGet;
	ConfigurationP.PacketRPD -> ConfRPDSend;
	ConfigurationP.ConfKDCPDGet -> ConfKDCPDGet;
	ConfigurationP.ConfKeyGet -> ConfKeyGet;
	
	ConfigurationP.SerialControl -> SerialActiveMessageC;
	
	ConfigurationP.SharedData -> SharedDataC.SharedData;
	ConfigurationP.ResourceArbiter -> SharedDataC.ResourceArbiter;
	
	ConfigurationP.Leds -> LedsC;
	
	ConfigurationP.Queue -> QueueC;
	
	MainC.SoftwareInit -> ConfigurationP.Init;
	
	Configuration = ConfigurationP.Configuration;
}
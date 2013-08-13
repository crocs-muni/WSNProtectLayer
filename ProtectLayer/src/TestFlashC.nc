/**
 * Configuration for the SharedData module to save data to the flash memory.
 * 
 * @author Filip Jurnecka
 */

#include "ProtectLayerGlobals.h"
configuration TestFlashC{
	provides {
		interface Init;
	}
}

implementation{
	components TestFlashP;
	
	components new SerialAMReceiverC(AM_FLASH_GET_MSG) as FlashGet;
	components new SerialAMReceiverC(AM_FLASH_SET_MSG) as FlashSet;
	components SerialActiveMessageC;
	components SharedDataC as Flash;
	components ConfigurationC;
	components LedsC;
	components MainC;
	
	components LoggerP;
	TestFlashP.Logger -> LoggerP;
	
	Init = TestFlashP.Init;
	
	TestFlashP.FlashGet -> FlashGet;
	TestFlashP.FlashSet -> FlashSet;
	TestFlashP.Packet -> FlashGet;
	
	TestFlashP.Flash -> Flash.ResourceArbiter;
	
	TestFlashP.SerialControl -> SerialActiveMessageC;
	
	TestFlashP.Leds -> LedsC;
	
	MainC.SoftwareInit -> TestFlashP.Init;
	TestFlashP.Configuration -> ConfigurationC;
}
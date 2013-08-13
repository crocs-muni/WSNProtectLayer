/**
 * Configuration that sets the logging to be performed via USB.
 * 
 * 	@version   0.1
 * 	@date      2012-2013
 */

#ifndef TOSSIM
#include "StorageVolumes.h"
#endif

configuration LoggerC{
	provides {
		interface Logger;
		interface Init;
	}
}

implementation{
	components LoggerP;
	components new SerialAMSenderC(AM_LOG_MSG);
	//receiver for the log msg to initialize memory readout
	components new SerialAMReceiverC(AM_LOG_MSG);
	components SerialActiveMessageC;
	
	#ifndef TOSSIM
	components new BlockStorageC(VOLUME_LOG);
	components UserButtonC;
	#endif
	components MainC;
	components LedsC;
	
	components new TimerMilliC();
	
	LoggerP.Leds -> LedsC;
	
	Logger = LoggerP.Logger;
	
	LoggerP.LowerAMSend -> SerialAMSenderC;
	LoggerP.Packet -> SerialAMSenderC;
	LoggerP.AMPacket -> SerialAMSenderC;
	LoggerP.Acks -> SerialAMSenderC;
	
	LoggerP.Receive -> SerialAMReceiverC;
	
	LoggerP.SerialControl -> SerialActiveMessageC;
	
	
	
	Init = LoggerP.Init;
	MainC.SoftwareInit -> LoggerP.Init;	
	#ifndef TOSSIM
	LoggerP.BlockRead -> BlockStorageC;
	LoggerP.BlockWrite -> BlockStorageC;
	LoggerP.Notify -> UserButtonC.Notify;
	LoggerP.Timer -> TimerMilliC;
	#endif
}
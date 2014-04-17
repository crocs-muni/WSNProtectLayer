#include "MessageStruct.h"
#include "EchoMsgStruct.h"

#define ZLOG_EPIR	64
#define HANSE3WIRE 	65

#define USED_SENSOR ZILOG_EPIR

configuration MainApp{
}
implementation{
	components MainC, MainAppP, LedsC;
	components new TimerMilliC() as Timer0;

#if USED_SENSOR == HANSE3WIRE
	components HanseC as MotionSensor;
#elif USED_SENSOR == ZILOG_EPIR 
	components ZilogC as MotionSensor;
#endif
	
	//networking (USART)
	components SerialActiveMessageC as AMC;
	components new SerialAMSenderC(AM_MOTIONDETECTIONMSG) as AMS;
	components new SerialAMReceiverC(AM_MOTIONDETECTIONMSG) as AMR;
	//networking (Wireless)
	components ActiveMessageC;
	components new AMReceiverC(AM_ECHO_MSG);
	components CC2420ActiveMessageC;
	
	components new QueueC(message_t *, 10) as UARTQueue;
	components new PoolC(message_t, 10) as UARTPool;
	
	MainAppP.Boot -> MainC.Boot;
	MainAppP.Sensor -> MotionSensor;
	MainAppP.Leds -> LedsC;
	MainAppP.Timer0 -> Timer0;
	
	//networking (USART)
	MainAppP.SSend -> AMS;
	MainAppP.AMC -> AMC;
	MainAppP.SReceive -> AMR;
	
	//networking (Wireless)
	MainAppP.RReceive -> AMReceiverC;
	MainAppP.Radio -> ActiveMessageC;
	
	MainAppP.CC2420Packet -> CC2420ActiveMessageC.CC2420Packet;
	
	MainAppP.UARTQueue -> UARTQueue;
	MainAppP.UARTPool -> UARTPool;
}
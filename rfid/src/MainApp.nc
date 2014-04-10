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
	
	//networking
	components ActiveMessageC as AMC;
	components new AMSenderC(6) as AMS;
	
	MainAppP.Boot -> MainC.Boot;
	MainAppP.Sensor -> MotionSensor;
	MainAppP.Leds -> LedsC;
	MainAppP.Timer0 -> Timer0;
	
	//networking
	MainAppP.Packet -> AMS;
	MainAppP.AMPacket -> AMS;
	MainAppP.AMSend -> AMS;
	MainAppP.AMC -> AMC;
}
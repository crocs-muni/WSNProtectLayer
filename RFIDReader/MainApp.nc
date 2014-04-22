
configuration MainApp{
}
implementation{
	components MainC, MainAppP, LedsC, ElBrick125C;
	//components new TimerMilliC() as Timer0;
	
	//networking
	components ActiveMessageC as AMC;
	components new AMSenderC(6) as AMS;
	
	MainAppP.Reader -> ElBrick125C;
	MainAppP.Leds -> LedsC;
	MainAppP.Boot -> MainC;
	
	//MainAppP.Timer0 -> Timer0;
	
	//networking
	MainAppP.Packet -> AMS;
	MainAppP.AMPacket -> AMS;
	MainAppP.AMSend -> AMS;
	MainAppP.AMC -> AMC;
}
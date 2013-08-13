
configuration ePIRC {
	provides {
		interface MovementSensor;
		interface Init;
	}
}
implementation {
	components MainC;
	components ePIRP;
	components new TimerMilliC() as Timer0; 
	
	MainC.SoftwareInit -> ePIRP.Init;	//auto-initialization
	
	MovementSensor = ePIRP.MovementSensor;
	Init = ePIRP.Init;

	ePIRP.Timer0 -> Timer0;
}

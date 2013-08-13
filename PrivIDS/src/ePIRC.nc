
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
	components RandomMlcgC;
	components StatsC;
	components LedsC;
	
	//MainC.SoftwareInit -> ePIRP.Init;	//auto-initialization
	
	
	
	MovementSensor = ePIRP.MovementSensor;
	Init = ePIRP.Init;

	ePIRP.Leds -> LedsC;
	ePIRP.Stats -> StatsC;
	ePIRP.Random -> RandomMlcgC.Random;
	ePIRP.RandomInit -> RandomMlcgC;
	ePIRP.Timer0 -> Timer0;
}

configuration HanseC{
	provides interface GeneralMotionSensorsI as GMSI;
}
implementation{
	components MainC, HanseP, HplMsp430GeneralIOC as GIO;
	components new TimerMilliC() as Timer0;
	
	GMSI = HanseP;
	
	HanseP.GND -> GIO.ADC0;
	HanseP.SENSE -> GIO.ADC1;
	
	//periodic check SENSE wire state (no interrupts)
	HanseP.Timer0 -> Timer0;
}
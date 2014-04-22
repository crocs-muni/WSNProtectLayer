configuration ZilogC {
	provides interface GeneralMotionSensorsI as GMSI;
}
implementation {
	components MainC, ZilogP;
	components new Msp430Usart0C() as Usart0;
	
	GMSI = ZilogP;
	
	//uart connection
	ZilogP.Usart0 -> Usart0;
	ZilogP.Usart0Res -> Usart0;
}
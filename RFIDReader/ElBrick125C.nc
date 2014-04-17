configuration ElBrick125C {
	provides interface GeneralRFIDI as GRFIDI;
}

implementation {
    components MainC, ElBrick125P, LedsC, HplMsp430GeneralIOC as GIO;
    components new Msp430Usart0C() as Usart0;
    components new TimerMilliC() as Timer0;

	ElBrick125P.SENSE -> GIO.ADC0;
      
    GRFIDI = ElBrick125P;
    
    ElBrick125P.Leds -> LedsC;
    ElBrick125P.Timer0 -> Timer0;
    
    ElBrick125P.Usart0 -> Usart0;
    ElBrick125P.Usart0Res -> Usart0;
    ElBrick125P.Usart0Int -> Usart0;
}
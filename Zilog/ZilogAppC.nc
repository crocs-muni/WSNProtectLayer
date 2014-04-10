configuration ZilogAppC{
}
implementation{ 
	components ZilogC, MainC, LedsC, SerialPrintfC;
	components new TimerMilliC() as Timer0;
	components new Msp430Usart0C() as Uart0;

	ZilogC.Boot -> MainC.Boot;
	ZilogC.Timer0 -> Timer0;
	ZilogC.Leds -> LedsC;
	ZilogC.Uart0 -> Uart0;
	ZilogC.Uart0Resource -> Uart0;
}

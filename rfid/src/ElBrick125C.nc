cofiguration ElBrick125 {
      provides interface GeneralRFIDI as GRFIDI;
}

implementation {
      components MainC, ElBrick125P;
      components new Msp430Usart0C() as Usart0;
      
      GRFIDI = ElBrick125P;
      
      ElBrick125P.Usart0 -> Usart0;
      ElBrick125P.Usart0Res -> Usart0;
}
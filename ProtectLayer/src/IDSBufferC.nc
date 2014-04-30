/**
 * Configuration IDSBufferC acts as a front-end for the IDSBufferP component. 
 * IDSBuffer is used to store packets into the buffer and to inform IntrusionDetectC that packet was
 * forwarded or dropped.
 * 
 *  @version   1.0
 * 	@date      2012-2014
 **/
 
 configuration IDSBufferC{
	provides {
		interface IDSBuffer;
	}
}
implementation{
	components IDSBufferP;
	components SharedDataC;
	
	IDSBuffer = IDSBufferP.IDSBuffer;
	
	IDSBufferP.SharedData -> SharedDataC;
}
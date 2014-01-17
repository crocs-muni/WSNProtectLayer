configuration IDSBufferC{
	provides {
		interface IDSBuffer;
	}
}
implementation{
	components IDSBufferP;
	
	IDSBuffer = IDSBufferP.IDSBuffer;
}
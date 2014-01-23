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
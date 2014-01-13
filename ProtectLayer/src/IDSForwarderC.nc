configuration IDSForwarderC {
}
implementation {
	components IDSForwarderP;
	components DispatcherC;
	
	IDSForwarderP.Receive -> DispatcherC.IDS_Receive;

}
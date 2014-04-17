configuration NodeListC {
	provides interface Init;
	provides interface NodeListI;
}
implementation{
	components NodeListP;
	components MainC;
	
	MainC.SoftwareInit -> NodeListP.Init;
	Init = NodeListP.Init;
	NodeListI = NodeListP.NodeListI;
	
	//NodeListP.insertOrUpdateNode = insertOrUpdateNode;
}
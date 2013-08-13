/**
 * The basic abstraction for routing component. 
 * 
 * 	@version   0.1
 * 	@date      2012-2013
 */



configuration RouteC {
	provides {
		interface Init;
		interface Route;
	}
}
implementation {
	components MainC;   
	components RouteP;
	components SharedDataC;
	components RandomC;
	
	RouteP.Random -> RandomC.Random;
	RouteP.SharedData -> SharedDataC.SharedData;
	
	MainC.SoftwareInit -> RouteP.Init;	//auto-initialization
	
	Init = RouteP.Init;
	Route = RouteP.Route;
}
/**
 * The basic abstraction for routing component. 
 * 
 * 	@version   0.1
 * 	@date      2012-2013
 */



configuration RouteC {
	provides {
		interface Init as PLInit;
		interface Route;
	}
}
implementation {   
	components RouteP;
	components SharedDataC;
	components RandomC;
	
	RouteP.Random -> RandomC.Random;
	RouteP.SharedData -> SharedDataC.SharedData;
	
	PLInit = RouteP.PLInit;
	Route = RouteP.Route;
}
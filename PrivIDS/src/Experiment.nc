#include "ProtectLayerGlobals.h"
#include "printf.h"


interface Experiment{


	command void startExperiment();
	
	event void ended();

}
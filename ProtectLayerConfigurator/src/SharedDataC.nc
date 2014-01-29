/**
 * Configuration for the SharedData module to save data to the flash memory.
 * 
 * 	@version   0.1
 * 	@date      2012-2013
 */

#ifndef TOSSIM
#include "StorageVolumes.h"
#endif

configuration SharedDataC{
	provides {
		interface SharedData;
                #ifndef TOSSIM
		interface ResourceArbiter;
                #endif
		interface Init;
	}
}

implementation{
	components SharedDataP;
	#ifndef TOSSIM
	components new BlockStorageC(VOLUME_SHAREDDATA) as FlashDataStorage;
	#endif
	
	components MainC;
	
	Init = SharedDataP.Init;

	SharedData = SharedDataP.SharedData;
	#ifndef TOSSIM
	ResourceArbiter = SharedDataP.ResourceArbiter;
	SharedDataP.FlashDataRead -> FlashDataStorage.BlockRead;
	SharedDataP.FlashDataWrite -> FlashDataStorage.BlockWrite;
	#endif
	
	MainC.SoftwareInit -> SharedDataP.Init;
}

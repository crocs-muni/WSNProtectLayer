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
		interface Init as PLInit;
	}
}

implementation{
	components SharedDataP;
	#ifndef TOSSIM
	components new BlockStorageC(VOLUME_SHAREDDATA) as SharedDataStorage;
	components new BlockStorageC(VOLUME_KEYS) as KeysDataStorage;
	#endif
	
	PLInit = SharedDataP.PLInit;

	SharedData = SharedDataP.SharedData;
	#ifndef TOSSIM
	ResourceArbiter = SharedDataP.ResourceArbiter;
	
	SharedDataP.KeysDataRead -> KeysDataStorage.BlockRead;
	
	SharedDataP.SharedDataRead -> SharedDataStorage.BlockRead;
	SharedDataP.SharedDataWrite -> SharedDataStorage.BlockWrite;
	#endif
}

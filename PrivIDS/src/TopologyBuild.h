#ifndef TOPOLOGYBUILD_H
#define TOPOLOGYBUILD_H

enum {
	SUPPRESS_AFTER_REBUILD = 80000, //during this period refuse rebuild beacon
	TOPOLOGY_PHASE_TIME  = 200000, //time to build routing table
	BEACON_SEND_PERIOD    = 40000, //beacon broadcasting period 
	CHILD_HELLO_SEND_PERIOD = 25000,
	REBUILD 	 = 1,   //msg_type
	BEACON 		 = 2,	//msg_type
	BASE_STATION = 3,	//msg_type
	CHILD_HELLO	 = 4,   //msg_type
	INFINITE 	 = 254,  //initial distance to BS for each node
	
	BASE_STATION_ID = 50,
	
	GRID_SIZE = 10,    // size of GRID topology in number of nodes 
	
	HEIGHT 		 = 20,  //size of GRID topology in number of nodes
	WIDTH		 = 30,   //size of GRID topology in number of nodes
	
	STATE_INIT	= 0,
	STATE_BEACONING = 1,
	STATE_CHILD_RECOGNITION = 2,
	STATE_BUILD_DONE 	= 3,
	
	

	SENDQUEUE_SIZE = 20,	
	AM_SENSORDATA  = 2,	//AM type for sensor_data_msg
	SENSOR_DATA    = 1,     //msg_type for regular sensor_data_msg
	FAKE           = 2,     //msg_type for fake sensor_data_msg

	MAX_FAKE_HOPS      = 4, //FP/DFP max propagation distance for fake msg
	MAX_BROADCAST_HOPS = 30,//broadcasting max propag. dist.	
	BS_AREA            = 7,	//DFP - decrease P_FAKE from this distance
	P_R                = 100,  //parent routing propability [%]
	P_FAKE             = 20    //propability of fake generation [%]
};

//TinyOS beaconing protocol special message
typedef nx_struct beacon_msg {
	nx_uint8_t msg_type;
	nx_uint8_t hop_count;	
} beacon_msg;

#endif

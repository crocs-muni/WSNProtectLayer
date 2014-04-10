#ifndef ZILOG_DEFS_H
#define ZILOG_DEFS_H

//commands
#define READ_MOTION_STATUS	0x61
#define SLEEP_MODE 		0x5A

//command response
#define READ_MS_Y		'Y'	//move detected
#define READ_MS_N		'N'	//nothing has been detected
#define READ_MS_U		'U'	//ePIR not stabilized or missing


//delay intervals etc
#define MEASURE_INTERVAL 	103 //millisecond timer
#define LOAD_INTERVAL 		309 




#endif

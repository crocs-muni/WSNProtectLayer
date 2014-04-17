#ifndef MSG_STRUCT_H
#define MSG_STRUCT_H


typedef nx_struct EchoMsg {
	nx_uint8_t version; 
	nx_uint16_t nodeid;
} EchoMsg;

enum {
	AM_ECHO_MSG = 0x35,
	AM_ECHO_VERSION = 1,
	
	AM_ECHO_INTERVAL = 90,
	AM_POWER = 3 //7
};

#endif /* MSG_STRUCT_H */

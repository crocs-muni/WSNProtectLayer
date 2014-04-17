#ifndef MESSAGE_STRUCT_H
#define MESSAGE_STRUCT_H

typedef nx_struct MotionDetectionMsg {
	//protocol version
	nx_uint8_t version;
	//operation or event ID
	nx_uint8_t operation;
	//rssi value
	nx_int16_t rssi;
	//node id	
	nx_uint16_t nodeid;
	
	//additional data
	nx_uint8_t dataPayload[8];
}MotionDetectionMsg;

enum {
	AM_MSG_VERSION = 3,
	AM_MOTIONDETECTIONMSG = 0x34,
	AM_RSSI_INVALID = 0xFFFF
};

enum MsgOperations {
	MSG_CHECK_MSG = 64,
	MSG_MOVE_DETECTED,
	MSG_ACK,
	MSG_NACK,
	MSG_ECHO_DETECTED,
	MSG_MOVEMENT_DETECTED
};

#endif /* MESSAGE_STRUCT_H */

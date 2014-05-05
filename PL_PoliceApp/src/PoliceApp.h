// $Id: PoliceApp.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef POLICEAPP_H
#define POLICEAPP_H

#define LOG_ONLY_SIM
#define PL_LOG_MAX_LEVEL 7

#define DEBUG_PRINTF
#define NEW_PRINTF_SEMANTICS

#define USE_CTP
#define CTP_DUMP_NEIGHBORS
//#define ACCEPT_ALL_SIGNATURES
//#define ACCEPT_ALL_MACS
//#define CTP_QUICK_INIT
#define TOS_BS_NODE_ID 19
//#define SKIP_MAGIC_PACKET
#define SKIP_EEPROM_RESTORE

enum {
  AM_POLICEAPP = 7,
  TIMER_PERIOD_MILLI = 2000,
  TIMER_STILL_ALIVE = 5000,
  TIMER_MOVEMENT_DETECTED = 30000,
  TIMER_MSN_DETECTED = 30000,
  MSGTYPE_STILLALIVE = 100,
  MSGTYPE_MOVEMENTDETECTED = 101,
  MSGTYPE_MSNDETECTED = 102,
  TIMER_START=5000,
  TIMER_FAIL_START=1000,
};

typedef nx_struct PoliceAppMsg_StillAlive {
  nx_uint16_t messageType; 
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} PoliceAppMsg_StillAlive;

typedef nx_struct PoliceAppMsg_MovementDetected {
  nx_uint16_t messageType; 
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} PoliceAppMsg_MovementDetected;

typedef nx_struct PoliceAppMsg_MSNDetected {
  nx_uint16_t messageType; 
  nx_uint16_t nodeid;
  nx_uint16_t msnid;
  nx_uint16_t counter;
} PoliceAppMsg_MSNDetected;


#endif 

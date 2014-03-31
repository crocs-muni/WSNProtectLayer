/*
 *      File with constants and structures. 
 *      Intended for early include into multiple components.
 *  	@author    Petr Svenda
 *  	@version   0.1
 *  	@date      2012-2013
 *  
 */
#ifndef PROTECTLAYERGLOBALS_H
#define PROTECTLAYERGLOBALS_H 

#include "message.h"

#define SKIP_MAGIC_PACKET 1

// Define following constant if you want to use buffered forwarder for 
// hop-by-hop forwarding to base station (Has more slots for messages
// than default forwarder which has only one slot.).
//#define USE_BUFFERED_FORWARDER 1

// Defines that first 8 bytes of the payload should be copied
// to the SPHeader (unencrypted). Helps to demonstrate functionality
// of the prototype during experiment. TODO: REMOVE THIS
#define PLAINTEXT_DEMO 1

// Conditional compilation for hop by hop encryption.
// Warning: DO NOT USE THIS OPTION!!!
//#define HOP_BY_HOP_ENCRYPTION 1
#ifdef HOP_BY_HOP_ENCRYPTION
#warning " *** WARNING: Hop-by-hop encryption is enabled! ***"
#endif

#define CTP_DUMP_NEIGHBORS

#ifdef CTP_QUICK_INIT
#warning " *** CTP QUICK INIT is defined, should not be in production! ***"
#endif

// Default base station node ID
#ifndef TOS_BS_NODE_ID
#define TOS_BS_NODE_ID 41
#endif

// Should be defined in application using this PL.
//#define THIS_IS_BS	

// If BS node
#if defined(TOS_NODE_ID) && defined(TOS_BS_NODE_ID) && !defined(THIS_IS_BS) && ((TOS_BS_NODE_ID)==(TOS_NODE_ID))
#define THIS_IS_BS
#endif
#ifdef THIS_IS_BS
#warning " *** THIS IS BASE STATION CODE ***"
#endif

// Allows printf outputs. Application should define this
//#define DEBUG_PRINTF
#ifndef DEBUG_PRINTF
#warning " *** PrintF is disabled, define DEBUG_PRINTF to enable it ***"
#endif

#ifdef ACCEPT_ALL_SIGNATURES
#warning " *** Warning! All signatures will be accepted !!! ***"
#endif

#ifdef ACCEPT_ALL_MACS
#warning " *** Warning! All MACs will be accepted !!! ***"
#endif

#ifdef SKIP_MAGIC_PACKET
#warning " *** Warning! Magic packet is skipped !!! ***"
#endif

// Define to supress warning from printf function
#ifndef PL_LOG_MAX_LEVEL 
#define PL_LOG_MAX_LEVEL 4
#endif

// Returns maximal value the given variable can have.
#define MAX_VALUE(var) ( (1<<(sizeof(var)*8-1)) | ((1<<(sizeof(var)*8-1))-1) )

#include <stdarg.h>
#include "ProtectLayerLog.h"

typedef enum _error_values {
    EDIFFERENTKEY = 100,            /**< different key was used to protect message */
    EINVALIDDECRYPTION = 101,       /**< invalid format of message to be decrypted */
    ENOTALLKEYSDISCOVERED = 102,    /**< not all keys were discovered */
    EKEYNOTFOUND = 103,             /**< requested key was not found */
    EDATANOTFOUND = 104,    	    /**< requested data structure was not found */
    EWRONGMAC = 105,		    /**< received mac does not match calculated one */	    
    EWRONGHASH = 106
} _error_values;

/**
        Various contants specified as enum to save stack space
*/
enum {
  AM_PROTECTLAYERRADIO = 128,
  AM_LOG_MSG = 129,
  AM_CON_GET_MSG = 130,
  AM_CON_SD_MSG = 131,
  AM_CON_PPCPD_MSG = 132,
  AM_CON_RPD_MSG = 133,
  AM_CON_KDCPD_MSG = 134,
  AM_FLASH_GET_MSG = 135,
  AM_FLASH_SET_MSG = 136,
  AM_INTRUSION_MSG = 137,
  AM_CHANGEPL = 138,
  AM_IDS_ALERT = 139,
  POLICEMAN_TIMER_MESSAGE_MILLI = 1000,
  INTRUDER_INITIAL_WAIT_MILLI = 10000,
  KEY_LENGTH = 16,
  MAX_NEIGHBOR_COUNT = 30,
  RECEIVE_BUFFER_LEN = 16,
  LOGGED_SIZE = 20,
  RSSI_THRESHOLD = -73,
  IDS_MAX_MONITORED_NEIGHBORS = 5,
  IDS_BUFFER_SIZE = 5,
  IDS_DROPPING_THRESHOLD = 50,
  IDS_MIN_PACKET_RECEIVED = 10,
  IDS_FORWARDER_SEND_BUFFER_LEN = 4,
  DROPPING_RATE = 75,
  PHANTOM_JUMPS=3,
  MAC_LENGTH = 16,
  HASH_LENGTH = 16,
  BLOCK_SIZE = 16,
  SIGNATURE_LENGTH = 16,
  COUNTER_SYNCHRONIZATION_WINDOW = 5,
  MAX_OFFSET = 20,
  NODE_MAX_ID = 50,
  INVALID_NODE_ID = 0xFFFE,
  MAGIC_WORD = 0x55,
  MAGIC_PACKET_RANDOM_OFFSET = 100,	/** constant offset before re-broadcasting magic packet. */
  MAGIC_PACKET_RANDOM_WINDOW = 200	/** random window before re-broadcasting magic packet. */
#ifdef PLAINTEXT_DEMO
  , PLAINTEXT_BYTES=4
 #endif
};

enum {
  STATE_INIT = 0,
  STATE_LOADED_FROM_EEPROM = 1,
  STATE_READY_TO_DEPLOY = 2,
  STATE_MAGIC_RECEIVED = 3,
  STATE_READY_FOR_APP = 4,
  STATE_WORKING = 5
}; 

#define PHANTOM_WALK_PROBABILITY (0.5)
#define IS_PHANTOM_WALK(x) ((x->privacyLevelIndicator & 0x80) == 0x80) 
#define SET_PHANTOM_WALK(x, y) do {x->privacyLevelIndicator = y ? x->privacyLevelIndicator | 0x80 : x->privacyLevelIndicator & ~0x80;} while(0)
#define GET_PRIVACY_LEVEL(x) (x->privacyLevelIndicator & ~0x80)
#define SET_PRIVACY_LEVEL(x,y) do {(x->privacyLevelIndicator = (x->privacyLevelIndicator & 0x80) | y);} while(0)




// NOTE: constants should be defined as item in enum above (to save space) #define MAX_NEIGHBOR_COUNT 	20 /**< Maximum number of neighbors - used to allocate static arrays */

#define FLAG_STATE_KDP_DISCOVERKEYS 0x0001	/**< neighbor keys discovery in progress */
#define FLAG_STATE_KDP_GETKEYTOBS   0x0002	/**< getting key to BS in progress */
#define FLAG_STATE_KDP_GETKEYTONODE 0x0004	/**< getting key to particular node in progress */

#define FLAG_STATE_CRYPTO_ENCRYPTION 0x0001	/**< encryption in progress (intentionally same as FLAG_STATE_CRYPTO_DECRYPTION) */
#define FLAG_STATE_CRYPTO_DECRYPTION 0x0001	/**< decryption in progress (intentionally same as FLAG_STATE_CRYPTO_ENCRYPTION) */
#define FLAG_STATE_CRYPTO_DERIV      0x0004	/**< key derivation in progress */
#define FLAG_STATE_CRYPTO_GENERATE   0x0008	/**< key generation in progress */

/**
	A structure representing request to send a message
*/
typedef struct _SendRequest {
/*@{*/
	uint16_t addr;	/**< target address */ 
	message_t* msg; /**< message to be send */
	uint8_t len;	/**< length of message to be send */
/*@}*/
} SendRequest_t;


/**
	A structure used to buffer incoming messages
*/
typedef struct _RecMsg {
/*@{*/
 	uint8_t isEmpty; 
	message_t* msg; /**< message to be received */
	void* payload;
	uint8_t len;	/**< length of message */
/*@}*/
} RecMsg_t;



/**
	A structure representing security header
*/
typedef struct SPHeader {
/*@{*/
  uint8_t msgType;	/**< type of message */
  uint8_t privacyLevelIndicator;	/**< MSb is used as a flag for Phantom routing, other bits indicate privacy level applied */
  uint16_t sender;	/**< sender ID */
  uint16_t receiver; /**< receiver ID */
#ifdef PLAINTEXT_DEMO
  uint8_t plaintext[PLAINTEXT_BYTES];
#endif
/*@}*/
} SPHeader_t;

/**
	The enumeration of possible message type
*/
typedef enum _MSG_TYPE {
	MSG_OTHER = 0,	/**< message of other (unknown) type */
	MSG_APP = 1,	/**< application message */
	MSG_IDS = 2,	/**< message of intrusion detection component */
	MSG_KDC = 3,	/**< message of key distribution component */
	MSG_ROUTE = 4,	/**< message of routing component */
	MSG_PLEVEL = 5, /**< message specifiying privacy level */
	MSG_FORWARD = 6, /**< message to be forwarded to BS */ 
	MSG_IDSCOPY = 7, /**< copy of message to be passed to IDS from Privacy component */
	MSG_COUNT = 8   /**< number of message types */
} MSG_TYPE;

/**
 * The enumeration of possible privacy levels:
 * 
 * 	0: No protection.
 *  1: MAC of the whole packet (SPHeader + payload).
 *  2: MAC + ENC (of the payload - excluding SPHeader).
 *  3: MAC + ENC + Phantom Routing.
 */
typedef enum _PRIVACY_LEVEL {
	PLEVEL_0 = 0,   /**< privacy level with no security       */
	PLEVEL_1 = 1,   /**< privacy level targeting attacker 1   */
	PLEVEL_2 = 2,   /**< privacy level targeting attacker 2   */
	PLEVEL_3 = 3,   /**< privacy level targeting attacker 3   */
	PLEVEL_NUM = 4  /**< synthetic value, maximum bound on PL */
} PRIVACY_LEVEL;
/**
	A structure representing a message that changes privacy level
*/
typedef struct PLevelMsg {
	uint8_t newPLevel; 				/**< new privacy level to be set */
	uint16_t counter; 				/**< hash count from the signature stored in the node */
	uint8_t signature[SIGNATURE_LENGTH]; /**< signature generated for this message, w.r.t. newPlevel, counter */
} PLevelMsg_t;


typedef struct AppMsg {
  uint8_t appID;
  uint8_t myType;
  uint8_t info;
} AppMsg_t;

/**
	A structure representing message exchanged between IDSs
*/
typedef struct IDSMsg {
/*@{*/
	// currently all broadcasted (reason for sender and receiver)
	// AM headers may be used instead, it's privacy question...
	uint16_t source;	/**< node that detected dropping and initiated this alert */
	uint16_t sender;	/**< sender (TOS_NODE_ID) */
	uint16_t receiver;	/**< receiver of this message */
	uint16_t nodeID;	/**< ID of a node we send the reputation about */
	uint16_t dropping;
//	uint8_t reputation;	/**< reputation */
/*@}*/	
} IDSMsg_t;

typedef struct IntrusionMsg {
	uint8_t counter;
} IntrusionMsg_t;

typedef enum _APP_MSG_TYPE {
	APPMSG_MOVEMENT = 1
} APP_MSG_TYPE;



typedef enum _APP_ID {
  APPID_POLICE = 1
} APP_ID;

/*
SavedData_t.txt
  targetID;SavedData.neigborID;KDCData.keyType;KDCData.keyValue;KDCData.dbgKeyID;IDSData.neighbor_reputation;IDSData.nb_messages;

PPCPrivData_t.txt
  targetID;PPCPrivData.priv_level;

RoutePrivData_t.txt
  targetID;RoutePrivData_t.parentNodeId;RoutePrivData_t.savedDataIdx;RoutePrivData_t.isValid;

KDCPrivData_t.txt
  targetID;KDCData.keyType;KDCData.keyValue;KDCData.dbgKeyID;

*/

enum {
	KEY_TOBS = 1,
	KEY_TONODE = 2,
	KEY_TOBSCRYPT = 3,
	KEY_TONODECRYPT = 4,
	KEY_TOBSMAC = 5,
	KEY_TONODEMAC = 6,
} KEY_TYPE;

typedef struct _key {
  uint8_t    keyType;
  uint8_t    keyValue[KEY_LENGTH];
  uint16_t	dbgKeyID;
  uint32_t 	counter;
} PL_key_t;

typedef uint16_t node_id_t;

// Saved data that are backed up in EEPROM
// struct only cause of the sending it via serial port
typedef struct KDCData {
    PL_key_t shared_key;
    uint8_t counter; 
} KDCData_t;

/**
	An IDS record about a neighbor
*/
typedef struct IDSData {
/*@{*/
	//uint8_t neighbor_reputation;	/**< reputation of a neighbor */
	uint32_t nb_received;	/**< number of received messages */
	uint32_t nb_forwarded;
	
/*@}*/
} IDSData_t;

/**
 * Data structure storing information about a neighbour saved by the protection layer component
 */
typedef struct SavedData {
	uint16_t nodeId; /**< id of the neighbouring node */
	KDCData_t kdcData; /**< information specific to the KDC component about the neighbour */
	IDSData_t idsData; /**< information specific to the IDS component about the neighbour */
} SavedData_t;

//structure for hash chain calculation
typedef struct Signature {
        uint8_t signature[SIGNATURE_LENGTH]; /**current hash */
        PRIVACY_LEVEL privacyLevel; /** privacy Level associated with this hash */
	uint16_t counter; /** distance from start of hash chain */
} Signature_t;

/**
 * Private data structure for the PPC component about this node
 */
typedef struct PPCPrivData {
	uint16_t priv_level;     			/**< current privacy level on this node */
	uint16_t global_counter; 			/**< global counter for privacy level change messages */
	Signature_t signatures[PLEVEL_NUM]; /**< signatures, separate for each privacy level */
} PPCPrivData_t;

/**
	Private data of the IDS
*/
typedef struct IDSPrivData {
/*@{*/
	//PRIVACY_LEVEL priv_level;
/*@}*/
} IDSPrivData_t;

typedef struct RoutePrivData {
	uint16_t parentNodeId;
	uint8_t isValid;
} RoutePrivData_t;

typedef struct KDCPrivData {
    PL_key_t	keyToBS;
    PL_key_t    hashKey;
} KDCPrivData_t;
/**
 * Structure combining all the data that need to be stored on the node by the protection layer
 */
typedef struct CombinedData {
	uint8_t magicWord;
	SavedData_t savedData[MAX_NEIGHBOR_COUNT]; /**< an array of information about the node's neighbours, first actualNeighborCount items should be valid */ 
	uint8_t	actualNeighborCount; /**< number of neighbors at the moment */
	PPCPrivData_t ppcPrivData; /**< private data structure for the PPC component */
    RoutePrivData_t routePrivData;
    KDCPrivData_t kdcPrivData; /**< private data structure for the key distribution component */
} combinedData_t;

/**
 * Message structure for logging messages
 */

typedef struct log_msg {
	uint16_t counter; /**< counter of the log message */
	uint8_t blockLength; /**< length of blocks required to be read from the flash memory at a time */
	uint8_t data[LOGGED_SIZE];
} log_msg_t;

/**
 * Message structure for the configuration get request message
 */
typedef struct con_get_msg {
	uint16_t counter; /**< counter of the configuration get message */
} con_get_msg_t;

/**
 * Message structure for the configuration component setting or announcing saved data structure
 */
typedef struct con_sd_msg {
	uint16_t counter; /**< counter of the configuration setting message */
	uint8_t savedDataIdx; /**< index of the savedData structure in the array */
	SavedData_t savedData; /**< the actual savedData structure with all the data */
} con_sd_msg_t;

/**
 * Message structure for the privacy protection layer component settings
 */
typedef struct con_ppcpd_msg {
	uint16_t counter; /**< counter of the privacy protection layer component settings message */ 
	PPCPrivData_t ppcPrivData; /**< the actual privacy protection layer data */
} con_ppcpd_msg_t;

typedef struct con_rpd_msg {
	uint16_t counter; /**< counter of the privacy protection layer component settings message */ 
	RoutePrivData_t rPrivData; /**< the actual privacy protection layer data */
} con_rpd_msg_t;

typedef struct con_kdcpd_msg {
	uint16_t counter; /**< counter of the privacy protection layer component settings message */ 
	KDCPrivData_t kdcPrivData; /**< the actual privacy protection layer data */
} con_kdcpd_msg_t;

/**
 * Message structure for the flash testing
 */
typedef struct flash_get_msg {
	uint16_t counter; /**< counter of the privacy protection layer component settings message */
} flash_get_msg_t;

/**
 * Message structure for the flash testing
 */
typedef struct flash_set_msg {
	uint16_t counter; /**< counter of the privacy protection layer component settings message */
} flash_set_msg_t;

typedef struct intrusion_msg {
	int8_t rssi;
	bool isIntruder; /**< if set to false, the intruder is in fact an authorized wearer of MSN */
} intrusion_msg_t;

/**
	Type for reputation of a neighbor
*/
typedef uint8_t NODE_REPUTATION;

/**
 * Enumeration of IDS status
 */
 typedef enum _IDS_STATUS {
	IDS_RESET = 0, //no security
	IDS_ON = 1, //
	IDS_OFF = 2  //
} IDS_STATUS;

/**
 * Structure of an item in an IDS buffer
 */
 typedef struct IDSBufferedPacket {
 	uint16_t sender;
 	uint16_t receiver;
 	uint32_t hashedPacket;
 } idsBufferedPacket_t;
//typedef uint64_t idsBufferedPacket_t;


enum {
#if PLATFORM_MICAZ || PLATFORM_TELOSA || PLATFORM_TELOSB || PLATFORM_TMOTE || PLATFORM_INTELMOTE2 || PLATFORM_SHIMMER || PLATFORM_IRIS
  FORWARD_PACKET_TIME_X = 7,
#else
  FORWARD_PACKET_TIME_X = 32,
#endif
  SENDDONE_OK_OFFSET_X        = FORWARD_PACKET_TIME_X,
  SENDDONE_OK_WINDOW_X        = FORWARD_PACKET_TIME_X,
  SENDDONE_FAIL_OFFSET_X      = FORWARD_PACKET_TIME_X  << 2,
  SENDDONE_FAIL_WINDOW_X      = SENDDONE_FAIL_OFFSET_X
};

/* 
 * The number of times the ForwarderBuffered will try to 
 * transmit a packet before giving up.
 */
enum {
  FWDER_MAX_RETRIES = 30,
  FWDER_FORWARD_COUNT = 8,  
  QUEUE_SIZE = FWDER_FORWARD_COUNT  
};

/*
 * An element in the ForwardingEngine send queue.
 * The client field keeps track of which send client 
 * submitted the packet or if the packet is being forwarded
 * from another node (client == 255). Retries keeps track
 * of how many times the packet has been transmitted.
 */
typedef struct {
  message_t * ONE_NOK msg;
  uint8_t len;
  uint8_t client;
  uint8_t retries;
} fwd_queue_entry_t;


/**
 * Warning!
 * If you want to generate Java Messages by MIG (genJavaMsgs.sh) you need to
 * define MIG - local definition will be used
 * 
 * MIG has trouble to include some needed header files, so they are included in MIGhlp.h.
 */
#ifndef MIG 
#include "Ctp.h"
#include "TreeRouting.h"
#else
#include "MIGhlp.h"
#endif

// basic message types
enum {
  AM_CTPRESPONSEMSG = 0xef,
  AM_COLLECTIONDEBUGMSG = 0x72,
  CTP_TIME_SEND_AFTER_START = 3000,
  CTP_TIME_SEND_AFTER_START_RND = 300,
  CTP_TIME_SENDING = 1500,
  CTP_TIME_SENDING_RND = 500,
  CTP_TIME_SEND_FAIL = 100,
  CTP_TIME_SEND_FAIL_RND = 50,
#ifdef CTP_QUICK_INIT  
  CTP_TIME_STOP_AFTER_BOOT = 8000,
  CTP_TIME_STOP_NO_PARENT = 8000,
#else
  CTP_TIME_STOP_AFTER_BOOT = 60000u,
  CTP_TIME_STOP_NO_PARENT = 60000u,
#endif  
  CTP_TIME_NOPARENT = 250u,
  CTP_TIME_NOPARENT_RND = 20u,
  CTP_STATE_INIT = 0,
  CTP_STATE_SENDING = 1,
  CTP_STATE_FIND_PARENT = 2,
  CTP_STATE_TERMINATE = 3,
  CTP_MAX_RAND_NEIGH=12,
  CTP_MAX_NEIGH=255u,
};

typedef nx_struct CtpResponseMsg {
    nx_uint8_t dummy;
} CtpResponseMsg;




#endif

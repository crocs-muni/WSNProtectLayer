/*
 *      Debug logging.
 *  	@author    Dusan Klinec (ph4r05)
 *  	@version   0.1
 *  	@date      1. 2. 2014 
 */
 
#ifndef PROTECTLAYERLOG_H_
#define PROTECTLAYERLOG_H_ 

#define PL_LOG_FATAL 0
#define PL_LOG_ERROR 1
#define PL_LOG_WARN 2
#define PL_LOG_INFO 3
#define PL_LOG_DEBUG 4
#define PL_LOG_TRACE 5
#define PL_LOG_DTRACE 6

#ifdef DEBUG_PRINTF
#include "printf.h"
#define INCLUDE_PRINTF() { \##include "printf.h" }
#define pl_printfflush() {printfflush();}
#define pl_printf(format, ...) {            \
	printf (format, ## __VA_ARGS__);		\
	printfflush();							\
}

/**
 * Declare maximum logging level/verbosity. 
 * Lower number means higher importance.
 *
 * The level conventions:
 *  - 0: fatal error
 *  - 1: error
 *  - 2: warning
 *  - 3: info
 *  - 4: debug
 *  - 5: trace
 *  - 6: more detailed trace
 *
 * Default: 4
 */
#ifndef PL_LOG_MAX_LEVEL
#  define PL_LOG_MAX_LEVEL   4                                                                                                                                               
#endif

/**
 * Internal function for logging messages with severity level and message class.
 */
void PLPrintDbg(int lvl, const char* messageClass, const char* formatString, ...);
                              
/**
 * Returns maximal log level allowed.
 * Just static at the moment. Can be extended if needed 
 * (e.g., to enable dynamic log level).
 */
#define pl_log_get_level() PL_LOG_MAX_LEVEL

/**
 * Writes log message. 
 *
 * @param lvl       The logging verbosity level. Lower number indicates higher
 *                  importance, with level zero indicates fatal error. Only
 *                  numeral argument is permitted (e.g. not variable).
 * @param tag       Logging class, will be prepended to the log message.
 * @param format	Printf formatting message
 * @param ...		Variable number of arguments for printf.
 *
 * Sample:pl_log(2, __FILE__, "Test code %d", code);
 * @hideinitializer
 */
#define pl_log(lvl,tag,format, ...) PLPrintDbg(lvl, tag, format, ## __VA_ARGS__)
      
// Previously was condition (saving space for unnecessary logs):
// do { 													 
// 		if (lvl <= pl_log_get_level()) 						 
// 	      PLPrintDbg_##lvl(lvl, tag, format, ## __VA_ARGS__); 	 
// } while (0)
//
// And several helper functions defined
// PLPrintDbg_0
// PLPrintDbg_1, ...


void PLPrintDbg(int lvl, const char* messageClass, const char* formatString, ...) {
	static const char *ltexts[] = { "F:", "E:", " W:", " I:", "D:", "T:", "C:"};
    va_list args;
    if (lvl < pl_log_get_level()) return;
    
    va_start(args, formatString);
    printf("%s %s:", ltexts[lvl], messageClass);
    printf(formatString, args);
    va_end(args);
}

#else
// No printf is allowed - just empty macros.else {
// Helps to save some code space if code is in production
// version.	
//
// do..while is for keeping the same code semantics (semicolon)
// required, in if conditions and so on... 

#define INCLUDE_PRINTF
#define pl_printf(format, ...) do{ }while(0)
#define pl_printfflush() do{ }while(0)
#define pl_log(lvl,tag,format, ...) do{ }while(0)
#endif


#endif // PROTECTLAYERLOG_H_ 

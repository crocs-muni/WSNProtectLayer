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
#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#define INCLUDE_PRINTF() { \##include "printf.h" }
#define pl_printfflush() {printfflush();}
#define pl_printf(format, ...) {            \
	printf (format, ## __VA_ARGS__);		\
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
static const char *ltexts[] = { "F:", "E:", " W:", "I:", "D:", "T:", "C:"};

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
#define pl_log(lvl,tag,format, ...)  								\
	 do {															\
 		if (lvl <= pl_log_get_level()) {						 	\
 	      PLPrintDbg_##lvl(lvl, tag, format, ## __VA_ARGS__); 	 	\
 	    }															\
 	} while (0)
      
#define PLPrintDbg_int(lvl,tag,format, ...) { 						\
		printf("%s %s: ", ltexts[lvl], tag);						\
		printf(format, ## __VA_ARGS__);								\
	}

#define pl_log_f(tag, format, ...) pl_log(0, tag, format, ## __VA_ARGS__)
#define pl_log_e(tag, format, ...) pl_log(1, tag, format, ## __VA_ARGS__)
#define pl_log_w(tag, format, ...) pl_log(2, tag, format, ## __VA_ARGS__)
#define pl_log_i(tag, format, ...) pl_log(3, tag, format, ## __VA_ARGS__)
#define pl_log_d(tag, format, ...) pl_log(4, tag, format, ## __VA_ARGS__)
#define pl_log_t(tag, format, ...) pl_log(5, tag, format, ## __VA_ARGS__)
#define pl_log_c(tag, format, ...) pl_log(6, tag, format, ## __VA_ARGS__)

//
// Varargs has following issues [http://www.eskimo.com/~scs/cclass/int/sx11c.html]
//
// "When a function with a variable-length argument list is called, the variable arguments 
// are passed using C's old ``default argument promotions.'' These say that types char 
// and short int are automatically promoted to int, and type float is automatically 
// promoted to double. Therefore, varargs functions will never receive arguments of type 
// char, short int, or float. Furthermore, it's an error to ``pass'' the type names char,
// short int, or float as the second argument to the va_arg() macro. Finally, for vaguely 
// related reasons, the last fixed argument (the one whose name is passed as the second 
// argument to the va_start() macro) should not be of type char, short int, or float, either."
//
void PLPrintDbg(int lvl, const char* messageClass, const char* formatString, ...) {
	
    va_list args;
    if (lvl < pl_log_get_level()) return;
    
    va_start(args, formatString);
    printf("%s %s: ", ltexts[lvl], messageClass);
    printf(formatString, args);
    va_end(args);
}

#if PL_LOG_MAX_LEVEL >= 0
#define PLPrintDbg_0(lvl,tag,format, ...) PLPrintDbg_int(lvl, tag, format, ## __VA_ARGS__)
#else
#define PLPrintDbg_0(lvl,tag,format, ...) do{ }while(0)
#endif

#if PL_LOG_MAX_LEVEL >= 1
#define PLPrintDbg_1(lvl,tag,format, ...) PLPrintDbg_int(lvl, tag, format, ## __VA_ARGS__)
#else
#define PLPrintDbg_1(lvl,tag,format, ...) do{ }while(0)
#endif

#if PL_LOG_MAX_LEVEL >= 2
#define PLPrintDbg_2(lvl,tag,format, ...) PLPrintDbg_int(lvl, tag, format, ## __VA_ARGS__)
#else
#define PLPrintDbg_2(lvl,tag,format, ...) do{ }while(0)
#endif

#if PL_LOG_MAX_LEVEL >= 3
#define PLPrintDbg_3(lvl,tag,format, ...) PLPrintDbg_int(lvl, tag, format, ## __VA_ARGS__)
#else
#define PLPrintDbg_3(lvl,tag,format, ...) do{ }while(0)
#endif

#if PL_LOG_MAX_LEVEL >= 4
#define PLPrintDbg_4(lvl,tag,format, ...) PLPrintDbg_int(lvl, tag, format, ## __VA_ARGS__)
#else
#define PLPrintDbg_4(lvl,tag,format, ...) do{ }while(0)
#endif

#if PL_LOG_MAX_LEVEL >= 5
#define PLPrintDbg_5(lvl,tag,format, ...) PLPrintDbg_int(lvl, tag, format, ## __VA_ARGS__)
#else
#define PLPrintDbg_5(lvl,tag,format, ...) do{ }while(0)
#endif

#if PL_LOG_MAX_LEVEL >= 6
#define PLPrintDbg_6(lvl,tag,format, ...) PLPrintDbg_int(lvl, tag, format, ## __VA_ARGS__)
#else
#define PLPrintDbg_6(lvl,tag,format, ...) do{ }while(0)
#endif

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

#define pl_log_f(tag,format, ...) 
#define pl_log_e(tag,format, ...) 
#define pl_log_w(tag,format, ...) 
#define pl_log_i(tag,format, ...) 
#define pl_log_d(tag,format, ...) 
#define pl_log_t(tag,format, ...) 
#define pl_log_c(tag,format, ...) 

#endif
#endif // PROTECTLAYERLOG_H_ 

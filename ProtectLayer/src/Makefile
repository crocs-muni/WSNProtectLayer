COMPONENT=ControllerAppC

BUILD_EXTRA_DEPS += TestLogger.class
CLEAN_EXTRA = *.class *Msg.java

INCLUDES= -I../../ProtectLayer/src  \
		  -I$(TOSDIR)/lib/printf	\
		  -I../../TOSCTP 			\
		  -I$(TOSDIR)/lib/net 		\
          -I$(TOSDIR)/lib/net/le	\
          -I$(TOSDIR)/lib/net/ctp

CFLAGS += $(INCLUDES)

TestLogger.class: $(wildcard TestLogger.java) LogMsg.java
	javac -target 1.6 -source 1.6 TestLogger.java -bootclasspath /usr/lib/jvm/java-1.7.0-openjdk-i386/jre/lib/rt.jar

LogMsg.java:
	mig java -target=null -java-classname=LogMsg ProtectLayerGlobals.h log_msg -o $@
	
	
include $(MAKERULES)

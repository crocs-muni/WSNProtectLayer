COMPONENT=ControllerAppC

BUILD_EXTRA_DEPS += TestLogger.class
CLEAN_EXTRA = *.class *Msg.java

CFLAGS += -I$(TOSDIR)/lib/printf

TestLogger.class: $(wildcard TestLogger.java) LogMsg.java
	javac -target 1.6 -source 1.6 TestLogger.java -bootclasspath /usr/lib/jvm/java-1.7.0-openjdk-i386/jre/lib/rt.jar

LogMsg.java:
	mig java -target=null -java-classname=LogMsg ProtectLayerGlobals.h log_msg -o $@
	
	
include $(MAKERULES)

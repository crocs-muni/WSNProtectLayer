COMPONENT=MainAppC

#BUILD_EXTRA_DEPS += TestLogger.class
BUILD_EXTRA_DEPS += LogMsg.java
BUILD_EXTRA_DEPS += FlashGetMsg.java
BUILD_EXTRA_DEPS += FlashSetMsg.java
BUILD_EXTRA_DEPS += SavedDataMsg.java

CLEAN_EXTRA = *.class *Msg.java

CFLAGS += -I$(TOSDIR)/lib/printf

#TestLogger.class: $(wildcard TestLogger.java) LogMsg.java
#	javac -target 1.6 -source 1.6 TestLogger.java -bootclasspath /usr/lib/jvm/java-1.7.0-openjdk-i386/jre/lib/rt.jar

folders:
	mkdir -p build 2>&1 1>/dev/null
	mkdir -p build/msg 2>&1 1>/dev/null

LogMsg.java: folders
	mig java -target=null -java-classname=LogMsg ProtectLayerGlobals.h log_msg -o build/msg/$@

FlashSetMsg.java: folders
	mig java -target=null -java-classname=LogMsg ProtectLayerGlobals.h flash_set_msg -o build/msg/$@

FlashGetMsg.java: folders
	mig java -target=null -java-classname=LogMsg ProtectLayerGlobals.h flash_get_msg -o build/msg/$@	
	
SavedDataMsg.java: folders
	mig java -target=null -java-classname=LogMsg ProtectLayerGlobals.h con_sd_msg -o build/msg/$@


include $(MAKERULES)

COMPONENT=ControllerAppC

CLEAN_EXTRA = *.class *Msg.java

CFLAGS += -I$(TOSDIR)/lib/printf

LogMsg.java:
	mig java -target=null -java-classname=LogMsg ProtectLayerGlobals.h log_msg -o $@
	
	
include $(MAKERULES)

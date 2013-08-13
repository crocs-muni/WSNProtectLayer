COMPONENT=ControllerAppC
BUILD_EXTRA_DEPS = BeaconMsg.py
CLEAN_EXTRA = BeaconMsg.py

CFLAGS += -I$(TOSDIR)/lib/printf \
		  -I$(TOSDIR)/lib/net \
		  -I$(TOSDIR)/lib/net/le \
          -I$(TOSDIR)/lib/net/ctp
          
CFLAGS += -DCC2420_DEF_RFPOWER=7 
CFLAGS += -DPRINTF_BUFFER_SIZE=500
CFLAGS += -DCC2420_DEF_CHANNEL=12

BeaconMsg.py: TopologyBuild.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=BeaconMsg TopologyBuild.h beacon_msg -o $@ 


	
include $(MAKERULES)

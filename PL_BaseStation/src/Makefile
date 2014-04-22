COMPONENT=BaseStationAppC
INCLUDES= -I../../ProtectLayer/src  \
		  -I$(TOSDIR)/lib/printf	\
		  -I../../TOSCTP 			\
		  -I$(TOSDIR)/lib/net 		\
          -I$(TOSDIR)/lib/net/le	\
          -I$(TOSDIR)/lib/net/ctp

CFLAGS += $(INCLUDES) -DPRINTF_BUFFER_SIZE=2048 -DCC2420_DEF_CHANNEL=15 
#-DCC2420_DEF_RFPOWER=31

include $(MAKERULES)

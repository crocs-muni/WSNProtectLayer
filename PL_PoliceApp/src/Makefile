COMPONENT=PoliceAppAppC

INCLUDES= -I../../ProtectLayer/src  \
		  -I$(TOSDIR)/lib/printf	\
		  -I../../TOSCTP 			\
		  -I$(TOSDIR)/lib/net 		\
          -I$(TOSDIR)/lib/net/le	\
          -I$(TOSDIR)/lib/net/ctp

CFLAGS += $(INCLUDES)
CFLAGS += -DPRINTF_BUFFER_SIZE=1000

include $(MAKERULES)

# 
#    Simviz send packet
#
#    1. Read TinyOS documenation before implementation 
#    http://docs.tinyos.net/tinywiki/index.php/TOSSIM#Variables


#    2. Edit makefile, see TinyOS documentation; (Example of makefile)
#    COMPONENT=PhantomHopbasedAppC
#
#    BUILD_EXTRA_DEPS = Message.py Message.class
#
#    Message.py: PhantomHopbased.h
#    mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=Message PhantomHopbased.h PhantomMsg -o $@
#
#    Message.class: Message.java
#    javac Message.java
#
#    Message.java: PhantomHopbased.h
#    mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=Message PhantomHopbased.h PhantomMsg -o $
#
#    include $(MAKERULES)


#    3. PhantomHopbased.h (Example of message definition)
#
#    #ifndef PHANTOMSECTORBASED_H
#    #define PHANTOMSECTORBASED_H
#
#    enum {
#        AM_PHANTOMMSG = 6,
#        TIMER_PERIOD_MILLI = 250
#    };
#
#    typedef nx_struct PhantomMsg {
#        nx_uint16_t nodeId;
#        nx_uint16_t counter;
#        nx_uint16_t pandaNode;  
#    } PhantomMsg;
#
#    endif


#    4.  Rebuild TinyOS component, call: make micaz sim


from Message import *

msg = Message()            

msg.set_pandaNode(10)                        
msg.set_nodeId(14)  

pkt = t.newPacket()
pkt.setData(msg.data)
pkt.setType(msg.get_amType())
pkt.setDestination(10)              
            
pkt.deliverNow(10)

print "Delivering \n" + str(msg);
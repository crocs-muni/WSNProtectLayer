#include "printf.h"
#include "ProtectLayerGlobals.h"


module StatsC{
	provides {
		interface Stats;
		}
	
}
implementation{
	
	int m_testNum=0;
	uint32_t m_sentEventMessages=0;
	uint32_t m_forwardedMessages=0;
	uint32_t m_dummyMessagesReceived=0;
	uint32_t m_receivedMessages = 0;
	uint32_t m_dummyMessagesSent=0;
	uint32_t m_eventsSensed=0;
	uint32_t m_parentMessagesReceived=0;
	uint32_t m_corruptedMessagesReceived=0;
	uint32_t m_messagesDropped=0;
	uint32_t m_idsMessagesDropped=0;
	uint32_t m_idsMessagesForwarded=0;
	uint32_t m_idsMessagesModified=0;
	uint32_t m_dropperNum=0;
	
	command float Stats.getParentLinkQuality()
	{
		//we assume that more messages were sent than received
		return (float) m_parentMessagesReceived/m_dummyMessagesSent;	
	}
	
	
	command void Stats.nextTest()
	{
		m_testNum++;
		m_sentEventMessages=0;
	 	m_forwardedMessages=0;
		m_dummyMessagesReceived=0;
		m_receivedMessages = 0;
		m_dummyMessagesSent=0;
		m_eventsSensed=0;
		m_parentMessagesReceived=0;
		m_corruptedMessagesReceived=0;
		m_messagesDropped=0;
		m_idsMessagesDropped=0;
		m_idsMessagesForwarded=0;
		m_idsMessagesModified=0;
	}
	
	command void Stats.dropper()
	{
		m_dropperNum++;
	}
	
	command void Stats.messageDropped()
	{
		m_messagesDropped++;
	}
	
	command void Stats.corruptedMessageReceived()
	{
		m_corruptedMessagesReceived++;
	}
	
	command void Stats.eventMessageSent()
	{
		m_sentEventMessages++;
	}
	
	command void  Stats.messageForwarded()
	{
		m_forwardedMessages++;
	}
	
	command void  Stats.dummyMessageSent()
	{
		m_dummyMessagesSent++;
		}
	
	command void  Stats.messageReceived() {
		m_receivedMessages++;
		}
	
	command void Stats.eventSensed()
	{
		m_eventsSensed++;
	}
	
	command void Stats.dummyMessageReceived()
	{
		m_dummyMessagesReceived++;
	}
	
	command void Stats.parentMessageReceived()
	{
		m_parentMessagesReceived++;
	}
	
	command void Stats.idsMessageDropped()
	{
		m_idsMessagesDropped++;
	}
	
	command void Stats.idsMessageForwarded()
	{
		m_idsMessagesForwarded++;
	}
	
	command void Stats.idsMessageModified()
	{
		m_idsMessagesModified++;
		}
	
	command uint32_t Stats.idsGetMessagesDropped()
	{
		return m_idsMessagesDropped;
		}
	
	command uint32_t Stats.idsGetMessagesForwarded()
	{
		return m_idsMessagesForwarded;
		}
	
	command void  Stats.printStats() 
	{
//		printf("Stats: test %d\n", m_testNum);
//		printf("Stats: EventsSensed: %lu\n", m_eventsSensed);	
//		printf("Stats: EventsMessagesSent: %lu\n", m_sentEventMessages);	
//		printf("Stats: MessagesFromChild: %lu\n", m_receivedMessages);	
//		printf("Stats: MessagesForwarded: %lu\n", m_forwardedMessages);	
//		printf("Stats: DummyMessagesSent: %lu\n", m_dummyMessagesSent);	
//		printf("Stats: DummyMessagesReceived: %lu\n", m_dummyMessagesReceived);			
//		printfflush();
//		printf("Stats: CorruptedMessages %lu\n", m_corruptedMessagesReceived);	
//		printf("Stats: MessagesFromParent: %lu\n", m_parentMessagesReceived);	
//		printf("Stats: DroppedMessages %lu\n", m_messagesDropped);
//		printf("Stats: idsDroppedMessages %lu\n", m_idsMessagesDropped);
//		printf("Stats: idsForwardedMessages %lu\n", m_idsMessagesForwarded);
//		printf("Stats: dropperNum %lu\n", m_dropperNum);
//		printfflush();	
		printf("test; %d; ", m_testNum);	
		printf("%lu; ", m_idsMessagesDropped);
		printf("%lu; ", m_idsMessagesForwarded);
		printf("%lu; ", m_sentEventMessages);
		printf("%lu; ", m_forwardedMessages);	
		printf("%lu; ", m_messagesDropped);
		printf("%lu; ", m_parentMessagesReceived);
		printf("%lu; ", m_dummyMessagesSent);
		printf("%lu; ", m_dummyMessagesReceived);			
		printf("\n");
		printfflush();		
	
	}
	
}
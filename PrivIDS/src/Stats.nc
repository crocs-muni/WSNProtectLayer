interface Stats{
	
	
	command float getParentLinkQuality();
	
	command void messageDropped();
	
	command void printStats();
	
	command void eventSensed();
	
	command void nextTest();
	
	command void eventMessageSent();
	
	command void messageForwarded();
	
	command void dummyMessageSent();
	
	command void messageReceived();
	
	command void dummyMessageReceived();
	
	command void parentMessageReceived();
	
	command void corruptedMessageReceived();
	
	command void idsMessageDropped();
	
	command void idsMessageForwarded();
	
	command void idsMessageModified();
	
	command uint32_t idsGetMessagesDropped();
	
	command uint32_t idsGetMessagesForwarded();
	
	command void dropper();
}
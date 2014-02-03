/**
 * The implementation of privacy component. It is abstracted by configuration PrivacyC.
 * 
 * 	@version   0.1
 * 	@date      2012-2013
 * 
 **/

#include "ProtectLayerGlobals.h"

module PrivacyP {
    uses {
        interface AMSend as LowerAMSend;
        interface Receive as LowerReceive;
        interface Packet;
        interface AMPacket;
        interface SplitControl as AMControl;
        interface IntrusionDetect;
        interface Init as IntrusionDetectInit; 
        interface Route;
        interface PrivacyLevel;
        interface SharedData;
        interface KeyDistrib;
        interface Crypto;
        interface Logger;
        interface Dispatcher;
        
        interface Timer<TMilli> as RetxmitTimer;
        interface Random;
    }
    
    provides {
        interface Init;
        interface Init as PLInit;
        interface Privacy;
        
        // parameterized interfaces for different message types
        interface AMSend as MessageSend[uint8_t id];	 
        interface Receive as MessageReceive[uint8_t id];
        interface SplitControl as MessageAMControl;
        //interface AMPacket as MessageAMPacket;	// TODO: implement
        interface Packet as MessagePacket;
    }	
}
implementation {
    PPCPrivData_t * m_privData = NULL;
    uint8_t reputation;
    bool m_radioBusy = FALSE;
    message_t* m_lastMsg = NULL;
    uint8_t m_lastMsgSender = 0;
    SPHeader_t* m_spHeader=NULL;
    SendRequest_t m_buffer[MSG_COUNT];
    uint8_t m_nextId=0;
    message_t* m_canceledMsg = NULL;
    // receive buffer
    message_t m_receiveMemoryBuffer[RECEIVE_BUFFER_LEN];
    RecMsg_t m_receiveBuffer[RECEIVE_BUFFER_LEN];
    uint8_t m_recNextToProcess=0;
    uint8_t m_recNextToStore=0;
    
    // Logging tag for this component
    static const char *TAG = "PrivacyP";
    
    static void startRetxmitTimer(uint16_t mask, uint16_t offset);
    
    //
    //	Init interface
    //
    command error_t Init.init() {
        uint8_t i=0;
        
        // Init receive buffer
        for(i = 0; i < RECEIVE_BUFFER_LEN; i++){
            m_receiveBuffer[i].msg = &m_receiveMemoryBuffer[i];
            m_receiveBuffer[i].isEmpty=1;
        }
        
        return SUCCESS;
    }
    
    command error_t PLInit.init() {
        
        m_privData = call SharedData.getPPCPrivData();
        // TODO PL setting probably here?
        m_privData->priv_level = PLEVEL_0;
        return SUCCESS;
    }
    
    //
    //	Privacy interface
    //
    command PRIVACY_LEVEL Privacy.getCurrentPrivacyLevel(){	
        pl_log_i(TAG, "Privacy.getCurerentPrivacyLevel, %d\n",m_privData->priv_level);
        return m_privData->priv_level;
    }
    
    
    //
    // PrivacyLevel interface
    //
    event void PrivacyLevel.privacyLevelChanged(error_t status, PRIVACY_LEVEL newPrivacyLevel){
        //TODO: check for allowed priv levels
        if (status == SUCCESS) {
            m_privData->priv_level = newPrivacyLevel;
            pl_log_i(TAG, "Privacy.privacyLevelChanged, %d\n",m_privData->priv_level);		
        }
    }
    
    /**
     * Passes message to the IDS for inspection.
     * Message processing in IDS is blocking synchronous thus the direct pointer
     * to the original message is passed to the IDS.
     * 
     * In case IDS implementation changes, this has to be refactored!
     * @Extension: If IDS operation gets asynchronous (e.g., start using tasks): 
     * 		Modify IDS to copy this message to internal buffer, use busy locks
     * 		to avoid overwriting message already in use.
     */
    void passToIDS(message_t* msg, void* payload, uint8_t len)
    {
    	message_t * newMsg = NULL;
        if (msg==NULL || payload==NULL){
        	pl_log_e(TAG, "pass2IDS ERR null\n");
        	return;
        }
        
        // Passing message directly to the IDS, sync. 
        newMsg = signal MessageReceive.receive[MSG_IDSCOPY](msg, payload, len);
        if (newMsg != msg){
        	pl_log_e(TAG, "IDS returned different buffer");
        }
    }
    
    /**
     * Returns whether given message type is 
     * subject to protect layer.
     */
    bool isSubjectToPL(uint8_t id){
        // Behavior switch based on interface parameter (id) 
        switch (m_nextId) {
        case (MSG_APP): {
        	// Apply protect layer, (mac/enc/phantom)	
        	return TRUE;
        }        
        case (MSG_IDS): {	// IDS forwarded as APP messages - Martin discussion 3.2.2014.
		    // Apply protect layer, (mac/enc/phantom)
            return TRUE;
        }
        case (MSG_FORWARD):{
            // Apply protect layer, (mac/enc/phantom). FWD is subject to PL (hop-by-hop protection).	
        	return TRUE;
        }
        case (MSG_PLEVEL):{
            // Protect level change is not subject to protection, simple re-broadcast.
            return FALSE;
            break;
        }
        default: {
            // By default, other messages are not subject to PL - simple send.
            return FALSE;
        }
        }
    }
    
    //
    // Receive interface - LowerReceive
    //
    task void task_receiveMessage() {
        message_t* retMsg = NULL;
        message_t* msg = NULL;
        uint8_t len = 0;
        void* payload = NULL;
        SPHeader_t* ourHeader = NULL;
        uint8_t decLen = 0;
        error_t status = SUCCESS;
        
        // Get msg to be processed
		msg = m_receiveBuffer[m_recNextToProcess].msg;
		
		// Test for empty message.
		if (m_receiveBuffer[m_recNextToProcess].isEmpty){
        	pl_log_e(TAG, "task_receiveMessage IS EMPTY!\n");
        	
        	// Message is already empty, no further action is needed.
        	return;
        }
        
        // Test for NULL message.
        if (msg==NULL){
        	pl_log_e(TAG, "task_receiveMessage IS NULL!\n");
        	
        	// Message is already empty, no further action is needed.
        	return;	
        }
        
        retMsg = msg;	// Default option, amy be changed later.
        
        // Get our header from payload
        ourHeader = (SPHeader_t*) m_receiveBuffer[m_recNextToProcess].payload;
        pl_log_d(TAG, "task_receiveMessage 2, buffer position %d\n", (int)m_recNextToProcess); 
        
        // SPHeader is not protected at all, data is in plaintext.
        if (ourHeader->receiver != TOS_NODE_ID){
        	// Message is not for me -> just report to the IDS and don't care anymore. 
        	// Even if encrypted, I don't have hop-by-hop keys so I cannot decrypt it for IDS.
        	// WARNING! Thus in privacy level >= 2 IDS cannot detect dropper since hashes are 
        	// always different in each hop. 
        	pl_log_d(TAG, "task_receiveMessage, ourHeader->receiver != TOS_NODE_ID\n"); 

            // It is not for me, pass copy to IDS
            passToIDS(msg, m_receiveBuffer[m_recNextToProcess].payload, m_receiveBuffer[m_recNextToProcess].len);
            
            // Nothing to do, free buffer taken by this message.
            goto recv_finish;
        }
        
        // TODO: test current privacy level vs. in message.
        // TODO: pick which privacy level act on. 
        if (ourHeader->privacyLevel != m_privData->priv_level){
        	pl_log_w(TAG, "MSG privLevel mismatch, msg=%u vs. current %u\n", ourHeader->privacyLevel, m_privData->priv_level);
        }
        
        // Message handling w.r.t. privacy level.
        // MAC verification and decryption.
        switch (ourHeader->privacyLevel) {
        case PLEVEL_0: {	// No protection
            break;
        }
        case PLEVEL_1: {	// MAC
        	// Verify MAC, result is stored to status
        	// The whole message is MACed (including SPHeader), so offset is zero.
        	status = call Crypto.verifyMacFromNodeB(ourHeader->sender, (uint8_t*) ourHeader, 0, &(m_receiveBuffer[m_recNextToProcess].len));
        	
        	pl_log_d(TAG, "task_receiveMessage, pl1, status=%d l=%u\n", status, m_receiveBuffer[m_recNextToProcess].len); 
            break;
        }
        case PLEVEL_2:		// MAC + ENC
        case PLEVEL_3: {	// MAC + ENC + Phantom 
        	
        	// Decrypt & verify MAC, result is stored to status.
            decLen = m_receiveBuffer[m_recNextToProcess].len - sizeof(SPHeader_t);                                
            status = call Crypto.unprotectBufferFromNodeB(ourHeader->sender, (uint8_t*) ourHeader, sizeof(SPHeader_t), &decLen);
            m_receiveBuffer[m_recNextToProcess].len = decLen + sizeof(SPHeader_t);
            
            pl_log_d(TAG, "task_receiveMessage, pl23, status=%d l=%u ln=%u\n", status, m_receiveBuffer[m_recNextToProcess].len, decLen); 
        	break;
        }
        default: 
        	pl_log_e(TAG, "task_receiveMessage: privacy level not recognized %u", ourHeader->privacyLevel);
        }
        
        // Pass message to the IDS in any case, message is for us,
        // if pl>=2, it is already decrypted.
        passToIDS(msg, m_receiveBuffer[m_recNextToProcess].payload, m_receiveBuffer[m_recNextToProcess].len);
        
        // Check result of the verification operation, if MAC is not correct, drop the message.
        if (status!=SUCCESS){
        	pl_log_i(TAG, "MACverification/decryption problem, code=%u, msg=%p", status, m_receiveBuffer[m_recNextToProcess].msg);
        	goto recv_finish;
        }
        
        // Handling of the message with respect to the message type.
        // Note: Message here is always for me.
        if (ourHeader->msgType == MSG_APP || ourHeader->msgType == MSG_IDS) {
			// Application message = Node sends message to the base station
			// Using forwarders on the path to the root. Hop by hop.
			// This message is re-wrapped as MSG_FORWARD.
        	pl_log_d(TAG, "task_receiveMessage, ourHeader->msgType == MSG_APP\n"); 
            
            //signal event to forwarder, this is special case since APP messages are forwarded to the BS and not to the app level
            retMsg = signal MessageReceive.receive[MSG_FORWARD](msg, m_receiveBuffer[m_recNextToProcess].payload, m_receiveBuffer[m_recNextToProcess].len);	
        } 
        else {   	
            pl_log_d(TAG, "Privacy: task_receiveMessage 4, ourHeader->msgType != MSG_APP, != MSG_IDS\n"); 
            
            // Payload is now including SPheader header. 
            // Stripe SPheader, provide offseted pointer and decrease payload length.
            len = m_receiveBuffer[m_recNextToProcess].len - sizeof(SPHeader_t);
            payload = m_receiveBuffer[m_recNextToProcess].payload + sizeof(SPHeader_t);

            pl_log_d(TAG, "LowerReceive.receive, MSG type %x.\n", ourHeader->msgType); 

            //TODO: test if our message, WTF?
            retMsg = signal MessageReceive.receive[ourHeader->msgType](msg, payload, len);
        }
        
recv_finish:        
        // Empty message_t slot, update which slot to process next and end task.
        atomic {
        m_receiveBuffer[m_recNextToProcess].msg = retMsg;
        m_receiveBuffer[m_recNextToProcess].isEmpty=1;
        m_recNextToProcess = (m_recNextToProcess+1)%RECEIVE_BUFFER_LEN;
        }
        
        return;	
    }	
    
    /**
     * Message received from the lower AM interface.
     * Message is stored to the buffer if there is space for it.
     */
    event message_t* LowerReceive.receive(message_t* msg, void* payload, uint8_t len) {
        
        message_t * tmpMsg = NULL;
        
        // Get new message_t to be returned.
        if (m_receiveBuffer[m_recNextToStore].isEmpty)
        {
        	atomic{
            tmpMsg = m_receiveBuffer[m_recNextToStore].msg; 
            m_receiveBuffer[m_recNextToStore].msg = msg;
            m_receiveBuffer[m_recNextToStore].payload = payload;
            m_receiveBuffer[m_recNextToStore].len = len;
            m_receiveBuffer[m_recNextToStore].isEmpty = 0;
            m_recNextToStore = (m_recNextToStore+1)%RECEIVE_BUFFER_LEN; // update pointer to next position to which next msg will be stored
            }
            
            pl_log_d(TAG, " 1 LowerREceive.receive, buffer #%u,p=%p\n", m_recNextToStore, msg);//  
        }
        else
        {
            // Buffer full, return original message without modification.
            return msg;
        }        

        post task_receiveMessage();        
        return tmpMsg;
    } 
    
    
    //
    //	AMSend[uint8_t id] interface
    //
    error_t sendMsgApp(SendRequest_t* sReq)
    {
        //behavior switch based on current privacy level
        sReq->addr = AM_BROADCAST_ADDR;
        
        switch (m_privData->priv_level) {
        case PLEVEL_0: {
            break;
        }
        case PLEVEL_1: {
            break;
        }
        case PLEVEL_2: {
            break;
        }
        case PLEVEL_3: {
            break;
        }
        default: 
            return FAIL;
        }
        return SUCCESS;
    }
    
    task void task_sendMessage(){
        SPHeader_t* spHeader = NULL;
        error_t rval=SUCCESS;
        error_t status=SUCCESS;
        SendRequest_t sReq; 
        uint8_t count=0;
        uint8_t encLen;
        bool applyPL=TRUE;
        
        // Check if radio is busy or not.
        // If busy, trigger retransmit timer and exit.
        if (m_radioBusy){
        	if (!call RetxmitTimer.isRunning()) {
        		// If retransmit timer is not running, start it with
        		// a randomized value. It will trigger this task again.
        		startRetxmitTimer(SENDDONE_FAIL_WINDOW, SENDDONE_FAIL_OFFSET);
        	}
        	
            return;
        }
        
        // Find next message to send in buffer.
        while(m_buffer[m_nextId].msg==NULL && count<MSG_COUNT){
            m_nextId=(m_nextId+1)%MSG_COUNT;
            count++;
        }
        
        if (count==MSG_COUNT) {
            return; // No message to send, buffer is empty
        }
        
        atomic {
        // Get info SendRequest from m_buffer.
        sReq.addr = m_buffer[m_nextId].addr;
        sReq.msg = m_buffer[m_nextId].msg;
        sReq.len = m_buffer[m_nextId].len;
        
        // Store msg pointer for further check in sendDone.	
        m_lastMsg = sReq.msg;
        m_lastMsgSender = m_nextId;
        }
        
        // Determine whether Protect layer should be applied
        // to this type of the message. 
        applyPL = isSubjectToPL(m_nextId);
        
        // SPHeader basic setup & check.
        // Check who is sending msg, if forwarding only, treat it differently.
        if (m_nextId == MSG_FORWARD)
        {
            // Message is sent by forwarder, (should forward packet).
            // SPHeader already present, just change receiver and sender field.
            spHeader =  (SPHeader_t *) call Packet.getPayload(sReq.msg, sReq.len);
            // Default routing is to the parent node
            spHeader->receiver = call Route.getParentID(); //TODO take care of a case if ID is not valid
            // add myself as a sender
            spHeader->sender = TOS_NODE_ID;
            // leave privacy type and msg type as is
        }
        else
        {
            // Initialize SP header to the message being sent.
            // Assumption: only MSG_FORWARD already has SP header set.
            // Payload is placed after SPHeader (getPayload in PL).
            //
            // If type = privacyLevelChange, broadcast to others, receiver is 
            // ignored in that case, MAC computation as well.
            
            //TODO add payload len check
            sReq.len += sizeof(SPHeader_t);
            
            spHeader = (SPHeader_t *) call Packet.getPayload(sReq.msg, sReq.len);
            // Setting info into our header
            spHeader->msgType = m_nextId; 
            spHeader->privacyLevel = m_privData->priv_level;
            //find out who is next hop
            spHeader->receiver = call Route.getParentID(); //TODO take care of a case if ID is not valid
            // add myself as a sender
            spHeader->sender = TOS_NODE_ID;
            
            // Init phantom routing if PL is applied and privacy level >= 3.
            if (applyPL && m_privData->priv_level == PLEVEL_3){
            	spHeader->phantomJumps = PHANTOM_JUMPS;
            } else {
            	spHeader->phantomJumps = 0;
            }
        }        
        
        // Behavior switch based on interface parameter (id) 
        // Changes destination in SPheader w.r.t. ID.
        // Apply end-to-end encryption for BaseStation if message is from application layer.
        switch (m_nextId) {
        case (MSG_APP): {
        	sendMsgApp(&sReq);
        	
        	// TODO: apply end-to-end encryption here, encrypt for basestation.
        	// TODO: verify correctness of use the parameters.
        	call Crypto.protectBufferForBSB((uint8_t *)spHeader, sizeof(SPHeader_t), &(sReq.len));
			break;
        }        
        case (MSG_IDS): {	// IDS forwarded as APP messages - Martin discussion 3.2.2014.
            sendMsgApp(&sReq);
            break;
        }
        default: {
        }
        }
        
        // If protect layer should be applied to this type of a message, take an action.
        if (applyPL){
        	// TODO: which privacy level to use? in message or current?
        	if (m_privData->priv_level == PLEVEL_3 && spHeader->phantomJumps > 0){
        		// TODO: If phantom routing, pick random neighbor and decrement
        		// phantom routing number in SPheader.
        		// If there are still some jumps to take, change destination in SP header.
        		// Otherwise the current parent is default destination.
        		// Should set destination before encryption & mac happens.
        		node_id_t randomNeighbor;
        		error_t hasRandomNeighbor = call Route.getRandomNeighborIDB(&randomNeighbor);
        		if (hasRandomNeighbor == SUCCESS){
        			spHeader->phantomJumps -= 1;
        			spHeader->receiver = randomNeighbor;
        			
        			pl_log_d(TAG, "task_sendMessage: phantomJumps=%u, newDestination=%u.\n", spHeader->phantomJumps, spHeader->receiver);
        		} else {
        			pl_log_w(TAG, "Cannot determine random neighbor for phantom routing.\n");
        		}
        	}
        	
        	// Message handling w.r.t. privacy level.
	        // MAC verification and decryption.
	        if (m_privData->priv_level == PLEVEL_1) { 
	        	// MAC.
	        	// Verify MAC, result is stored to status
	        	// The whole message is MACed (including SPHeader), so offset is zero.
	        	status = call Crypto.macBufferForNodeB(spHeader->receiver, (uint8_t *)spHeader, 0, &(sReq.len));
	        	pl_log_d(TAG, "task_sendMessage, pl1, status=%d l=%u\n", status, sReq.len); 
	            
	        } else if (m_privData->priv_level == PLEVEL_2 || m_privData->priv_level == PLEVEL_3){
	        	// MAC + ENC.
	        	// MAC + ENC + Phantom.
				
	        	// TODO: finish with new interface, verify len parameter correctness (right usage?)
	        	rval = call Crypto.protectBufferForNodeB(spHeader->receiver, (uint8_t *)spHeader, sizeof(SPHeader_t), &(sReq.len));
	            
	            pl_log_d(TAG, "task_sendMessage, pl23, status=%d l=%u\n", status, sReq.len); 
	        	
	        }
        }
        
        // Pass prepared message to the lower layer for sending.
        rval = call LowerAMSend.send(sReq.addr,sReq.msg,sReq.len);
        if(rval == SUCCESS) {
            // Message accepted for sending by lower AM layer.
            m_radioBusy=TRUE; 
            
            pl_log_d(TAG, "sendtask, lowSend=%p c=%d ln=%d\n", sReq.msg, m_lastMsgSender, sReq.len);
            
        } else {
        	if (!call RetxmitTimer.isRunning()) {
        		startRetxmitTimer(SENDDONE_FAIL_WINDOW, SENDDONE_FAIL_OFFSET);
        	}
        	
        	pl_log_d(TAG, "sendtask, lowSend fail=%p, code=%d\n", sReq.msg, rval);
        }
        
        return;
    }
    
    /**
     * AMSend entrypoint for privacy layer. 
     */
    command error_t MessageSend.send[uint8_t id](am_addr_t addr, message_t* msg, uint8_t len) {        
        // check if Id is within bounds
        if (id>=MSG_COUNT){
        	pl_log_e(TAG, "send: Unsupported message id %u\n", id);
            return FAIL;
        }
        
        // check if radio is busy for this id
        if (m_buffer[id].msg!=NULL) {
            //dbg("Privacy","Privacy: PrivacyP.MessageSend.send, buffer for id %d is full\n",id);
            pl_log_d(TAG, "send: buffer for id %u full\n", id);
            return EBUSY;
        }
        
        // put message into buffer
        atomic{
        m_buffer[id].addr = addr;
        m_buffer[id].msg = msg;
        m_buffer[id].len = len;
        }
                
        // is the radio busy?
        if (!m_radioBusy){
            post task_sendMessage();
        } else { 
        	startRetxmitTimer(SENDDONE_FAIL_WINDOW, SENDDONE_FAIL_OFFSET);
        }
        
        return SUCCESS;
    }
    
    /**
     * Starts retransmit timer, time is random within a given window
     * plus given constant offset.  
     */
    static void startRetxmitTimer(uint16_t window, uint16_t offset) {                                                                                                      
	    uint16_t r = call Random.rand16();
	    r %= window;
	    r += offset;
	    call RetxmitTimer.startOneShot(r);
    }
	
    event void RetxmitTimer.fired() {                                                                                                                                      
	    post task_sendMessage();
    }
    
    /**
     * Message cancel is not supported operation.
     */
    command error_t MessageSend.cancel[uint8_t id](message_t* msg) {
        return FAIL; 
    }
    
    command uint8_t MessageSend.maxPayloadLength[uint8_t]() {
        // We will reserve some length for our header
        return (uint8_t) (call LowerAMSend.maxPayloadLength() - sizeof(SPHeader_t));
    }
    
    command void* MessageSend.getPayload[uint8_t](message_t* msg, uint8_t len) {
        // Get payload
        void* tmp = call LowerAMSend.getPayload(msg, (uint8_t) (len + sizeof(SPHeader_t)));
        // Return payload offset after our header
        return tmp + sizeof(SPHeader_t);
    }
    
    default event void MessageSend.sendDone[uint8_t](message_t* msg, error_t error) {}
    
    //
    // MessageReceive
    //
    default event message_t* MessageReceive.receive[uint8_t id](message_t* msg, void* payload, uint8_t len) { 		
    return msg; 
} 
    //
    //	LowerAMSend interface
    //
    event void LowerAMSend.sendDone(message_t* msg, error_t error) {
    //test if our message was sent
    if (m_lastMsg != msg)
    return;
    
    // Send done -> send operation ended, buffer is not needed anymore, can be released
    // for new incoming messages. Reset buffer, move to next ID, set radio not busy.
    atomic {
    m_buffer[m_nextId].addr = 0;
    m_buffer[m_nextId].msg = NULL;
    m_buffer[m_nextId].len = 0;
    m_nextId = (m_nextId+1)%MSG_COUNT;
    m_radioBusy = FALSE;
    }
    
    // Schedule sending task, randomize task start (flattens peaks).
    startRetxmitTimer(SENDDONE_OK_WINDOW, SENDDONE_OK_OFFSET);
    pl_log_d(TAG, "sendtask, lowSendDone, p=%p c=%d code=%d\n", msg, m_lastMsgSender, error);
    
    // Signal to particular interface 
    signal MessageSend.sendDone[m_lastMsgSender](msg, error);
}

	//
	// Radio & ProtectLayer initialization
	//

    void radioStartDone(error_t err);
    task void radioStart(){
    	error_t err = call AMControl.start();
    	
    	// The returned value can be also EALREADY in which
    	// case startDone is not called, so in order to prevent
    	// being stuck here call it manually.
    	if (err!=SUCCESS){
    		radioStartDone(err);
    	}
    }
    
    task void radioStarted(){
    	pl_log_i(TAG, "radio started.");
    	call Dispatcher.serveState();
    }
    
    void radioStartDone(error_t err){
    	if (err == SUCCESS || err==EALREADY) {
    		// Radio was started successfully or was already started.
    		// In both cases proceed to PL initialization in
    		// a Dispatcher. This is done in a task
    		// since initialization can take a long time.
		    post radioStarted();
		    
		} else {
			// Starting the radio was not successful.
			// Try it again in  
			post radioStart();
		}
    }
    
    command void Privacy.startApp(error_t err) {
        // Dispatcher has everything initialized right now.
		pl_log_d(TAG, "Going to signal message AMControl.startDone()\n");
		signal MessageAMControl.startDone(err);
    }
    
    //
    // AMControl interface
    //
    event void AMControl.startDone(error_t err) {
	    radioStartDone(err);
    }
    	
    event void AMControl.stopDone(error_t err) {
        // do nothing
    }	
    
    //
    // MessageAMControl (aka SplitPhase) interface
    //	
    command error_t MessageAMControl.start() {
    pl_log_i(TAG, "NodeState: <MessageAMControl>\n"); 
	
	// For real operation, radio has to be started at first
	// due to routing, key establishment, etc...
	// Radio start is done in task, until start is successful.
	post radioStart();
    return SUCCESS;	
}
    command error_t MessageAMControl.stop() {
    return SUCCESS;	
}
    default event void MessageAMControl.startDone(error_t err) {} 
    
    //
    //	MessagePacket
    //	
    command void MessagePacket.clear(message_t* msg) {
    call Packet.clear(msg);
}
    command uint8_t MessagePacket.payloadLength(message_t* msg) {
    //TODO return value depending on privacy level 
    return (uint8_t) (call Packet.payloadLength(msg) - sizeof(SPHeader_t));
}
    command void MessagePacket.setPayloadLength(message_t* msg, uint8_t len) {
    call Packet.setPayloadLength(msg, (uint8_t)(len + sizeof(SPHeader_t)));
}
    command uint8_t MessagePacket.maxPayloadLength() {
    //TODO return value depending on privacy level 
    return (uint8_t)(call Packet.maxPayloadLength() - sizeof(SPHeader_t));
}
    command void* MessagePacket.getPayload(message_t* msg, uint8_t len) {
    // Get payload
    void* tmp = call Packet.getPayload(msg, (uint8_t) (len + sizeof(SPHeader_t)));
    // Return payload offset after our header
    return tmp + sizeof(SPHeader_t);
}
    
    //
    // Route
    //
    event void Route.randomNeighborIDprovided(error_t status, node_id_t id){
    // do nothing
}	
    event void Route.randomParentIDprovided(error_t status, node_id_t id){
    // do nothing
}
    
/*
    //
    // KeyDistrib
    //
    event void KeyDistrib.getKeyToBSDone(error_t result, PL_key_t *pBSKey){
        // TODO Auto-generated method stub
    }
    
    event void KeyDistrib.discoverKeysDone(error_t result){
        // TODO Auto-generated method stub
    }
    
    event void KeyDistrib.getKeyToNodeDone(error_t result, PL_key_t *pNodeKey){
        // TODO Auto-generated method stub
    }
*/

    
/*
    //
    // Crypto
    //
    event void Crypto.decryptBufferDone(error_t status, uint8_t *buffer, uint8_t resultLen){
        // TODO Auto-generated method stub
    }
    
    event void Crypto.deriveKeyDone(error_t status, PL_key_t *derivedKey){
        // TODO Auto-generated method stub
    }
    
    event void Crypto.generateKeyDone(error_t status, PL_key_t *newKey){
        // TODO Auto-generated method stub
    }
    
    event void Crypto.encryptBufferDone(error_t status, uint8_t *buffer, uint8_t resultLen){
        // TODO Auto-generated method stub
    }
*/

    //
    // interface Logger
    //
    event void Logger.logToPCDone(message_t *msg, error_t error){
    	// TODO Auto-generated method stub
	}
} 
    

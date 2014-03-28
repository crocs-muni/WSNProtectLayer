#include "ProtectLayerGlobals.h"

/**
 * This if only a draft implementation!
 * Forwarding should be done like in CTP engine, with retransmit timer
 * and with tasks.
 * 
 */
#include "ProtectLayerGlobals.h"
module ForwarderBufferedP 
{
	provides {
		interface Init;
		}
#ifndef THIS_IS_BS
	uses {
		interface AMSend as SubSend;
		interface Receive;
		
    	// RetxmitTimer is for timing packet sends for improved performance
    	interface Timer<TMilli> as RetxmitTimer;
    	interface Random;
    	
    	// These four data structures are used to manage packets to forward.
	    // SendQueue and QEntryPool are the forwarding queue.
	    // MessagePool is the buffer pool for messages to forward.
	    // SentCache is for suppressing duplicate packet transmissions.
	    interface Queue<fwd_queue_entry_t*> as SendQueue;
	    interface Pool<fwd_queue_entry_t> as QEntryPool;
	    interface Pool<message_t> as MessagePool;
	}
#endif
}
implementation{
#ifndef THIS_IS_BS
	static const char *TAG = "FwdBuffP";

  /* Helper functions to start the given timer with a random number
   * masked by the given mask and added to the given offset.
   */
  static void startRetxmitTimer(uint16_t mask, uint16_t offset);
  void clearState(uint8_t state);
  bool hasState(uint8_t state);
  void setState(uint8_t state);
  void packetComplete(fwd_queue_entry_t * qe, message_t * msg, bool success);
	
  // CTP state variables.
  enum {
    QUEUE_CONGESTED  = 0x1, // Need to set C bit?
    ROUTING_ON       = 0x2, // Forwarding running?
    RADIO_ON         = 0x4, // Radio is on?
    ACK_PENDING      = 0x8, // Have an ACK pending?
    SENDING          = 0x10 // Am sending a packet?
  };

  // Start with all states false
  uint8_t forwardingState = 0; 
  
  /* Keep track of the last parent address we sent to, so that
     unacked packets to an old parent are not incorrectly attributed
     to a new parent. */
  am_addr_t lastParent;
  
  /* Network-level sequence number, so that receivers
   * can distinguish retransmissions from different packets. */
  uint8_t seqno;
  
  /* Simple forwarder with only one client. */
  fwd_queue_entry_t clientEntries;
  fwd_queue_entry_t* ONE_NOK clientPtrs;

  /* The loopback message is for when a collection roots calls
     Send.send. Since Send passes a pointer but Receive allows
     buffer swaps, the forwarder copies the sent packet into 
     the loopbackMsgPtr and performs a buffer swap with it.
     See sendTask(). */
     
  message_t loopbackMsg;
  message_t* ONE_NOK loopbackMsgPtr;

  command error_t Init.init() {
    
    clientPtrs = &clientEntries;
    loopbackMsgPtr = &loopbackMsg;
    seqno = 0;
    //lastParent = call AMPacket.address();
    
    // clear send queue
    while(call SendQueue.empty()==FALSE){
    	call SendQueue.dequeue();
    }
    
    setState(ROUTING_ON);
    return SUCCESS;
  }

  /*command error_t StdControl.start() {
    setState(ROUTING_ON);
    if (!call SendQueue.empty()) {
        post sendTask();
    }
    return SUCCESS;
  }

  command error_t StdControl.stop() {
    clearState(ROUTING_ON);
    return SUCCESS;
  }*/

  /* sendTask is where the first phase of all send logic
   * exists (the second phase is in SubSend.sendDone()). */
  task void sendTask();

  static void startRetxmitTimer(uint16_t window, uint16_t offset) {
    uint16_t r = call Random.rand16();
    r %= window;
    r += offset;
    call RetxmitTimer.startOneShot(r);
    dbg("Forwarder", "Rexmit timer will fire in %hu ms\n", r);
  }
  
  /*command error_t Send.cancel[uint8_t client](message_t* msg) {
    // cancel not implemented. will require being able
    // to pull entries out of the queue.
    return FAIL;
  }

  command uint8_t Send.maxPayloadLength[uint8_t client]() {
    return call Packet.maxPayloadLength();
  }

  command void* Send.getPayload[uint8_t client](message_t* msg, uint8_t len) {
    return call Packet.getPayload(msg, len);
  }*/

  /*
   * These is where all of the send logic is. When the ForwardingEngine
   * wants to send a packet, it posts this task. The send logic is
   * independent of whether it is a forwarded packet or a packet from
   * a send clientL the two cases differ in how memory is managed in
   * sendDone.
   *
   * The task first checks that there is a packet to send and that
   * there is a valid route. It then marshals the relevant arguments
   * and prepares the packet for sending. If the node is a collection
   * root, it signals Receive with the loopback message. Otherwise,
   * it sets the packet to be acknowledged and sends it. It does not
   * remove the packet from the send queue: while sending, the 
   * packet being sent is at the head of the queue; a packet is dequeued
   * in the sendDone handler, either due to retransmission failure
   * or to a successful send.
   */

  task void sendTask() {
    //uint16_t gradient;
    dbg("Forwarder", "%s: Trying to send a packet. Queue size is %hhu.\n", __FUNCTION__, call SendQueue.size());
    
    if (hasState(SENDING) || call SendQueue.empty()) {
    	//call CollectionDebug.logEventDbg(NET_C_FE_SENDQUEUE_EMPTY, hasState(SENDING), call SendQueue.empty(), 0);
      	return;
    }
    else if (FALSE) {
      /* This code path is for when we don't have a valid next
       * hop. We set a retry timer.
       *
       * Technically, this timer isn't necessary, as if a route
       * is found we'll get an event. But just in case such an event
       * is lost (e.g., a bug in the routing engine), we retry.
       * Otherwise the forwarder might hang indefinitely. As this test
       * doesn't require radio activity, the energy cost is minimal. */
      //dbg("Forwarder", "%s: no route, don't send, try again in %i.\n", __FUNCTION__, NO_ROUTE_RETRY);
      //call RetxmitTimer.startOneShot(NO_ROUTE_RETRY);
      
      pl_log_w(TAG, "NoRoute\n");
      //call CollectionDebug.logEvent(NET_C_FE_NO_ROUTE);
      return;
    }
    else {
      /* We can send a packet.
	 First check if it's a duplicate;
	 if not, try to send/forward. */
      error_t subsendResult;
      fwd_queue_entry_t* qe = call SendQueue.head();
	  bool nullMsg = qe->msg==NULL || qe==NULL;

      if (nullMsg) {
		/* This packet is a duplicate, so suppress it: free memory and
		 * send next packet.  Duplicates are only possible for
		 * forwarded packets, so we can circumvent the client or
		 * forwarded branch for freeing the buffer. */
		pl_log_w(TAG, "NullMessage\n"); 
	
        call SendQueue.dequeue();
		if (call MessagePool.put(qe->msg) != SUCCESS) 
		  pl_log_w(TAG, "MsgPoolErr\n"); //call CollectionDebug.logEvent(NET_C_FE_PUT_MSGPOOL_ERR); 
		if (call QEntryPool.put(qe) != SUCCESS) 
		  pl_log_w(TAG, "QEntryErr\n"); //call CollectionDebug.logEvent(NET_C_FE_PUT_QEPOOL_ERR); 
	  
        post sendTask();
        return;
      }
      
      // Not a duplicate: we've decided we're going to send.
      dbg("Forwarder", "Sending queue entry %p\n", qe);
	
	  /* The basic forwarding/sending case. */
	  //call CtpPacket.setEtx(qe->msg, gradient);
	  //call CtpPacket.clearOption(qe->msg, CTP_OPT_ECN | CTP_OPT_PULL);
	  /*if (call PacketAcknowledgements.requestAck(qe->msg) == SUCCESS) {
  	    setState(ACK_PENDING);
  	  }
	  if (hasState(QUEUE_CONGESTED)) {
	    call CtpPacket.setOption(qe->msg, CTP_OPT_ECN); 
	    clearState(QUEUE_CONGESTED);
	  }*/
	
	  subsendResult = call SubSend.send(AM_BROADCAST_ADDR, qe->msg, qe->len);
	  if (subsendResult == SUCCESS) {
	    // Successfully submitted to the data-link layer.
	    setState(SENDING);
	    dbg("Forwarder", "%s: subsend succeeded with %p.\n", __FUNCTION__, qe->msg);
	  
	    return;
	  }
	  // The packet is too big: truncate it and retry.
	  else if (subsendResult == ESIZE) {
	    dbg("Forwarder", "%s: subsend failed from ESIZE: truncate packet.\n", __FUNCTION__);
	    //call Packet.setPayloadLength(qe->msg, call Packet.maxPayloadLength());
	    post sendTask();
	    pl_log_w(TAG, "SubSend ESIZE\n");
	    //call CollectionDebug.logEvent(NET_C_FE_SUBSEND_SIZE);
	  }
	  else {
	    dbg("Forwarder", "%s: subsend failed from %i\n", __FUNCTION__, (int)subsendResult);
	  
	    // ph4r05 failed send - inform, may be problem with subsend engine
	    //call CollectionDebug.logEventDbg(0x64, subsendResult, gradient, qe->retries);
	    pl_log_w(TAG, "sendFailed\n");
	  
	    // TODO: manipulate with retries count?
	    qe->retries-=1;
	    if (qe->retries<=0){
	  	  // delete from queue
	  	  call SubSend.cancel(qe->msg);
	  	  call SendQueue.dequeue();
          //clearState(SENDING);
          startRetxmitTimer(SENDDONE_OK_WINDOW_X, SENDDONE_OK_OFFSET_X);
		  packetComplete(qe, qe->msg, FALSE);
	    }
	  
	    // try again
	    startRetxmitTimer(SENDDONE_FAIL_WINDOW_X, SENDDONE_FAIL_OFFSET_X);
	  }
    }
  }


  /*
   * The second phase of a send operation; based on whether the transmission was
   * successful, the ForwardingEngine either stops sending or starts the
   * RetxmitTimer with an interval based on what has occured. If the send was
   * successful or the maximum number of retransmissions has been reached, then
   * the ForwardingEngine dequeues the current packet. If the packet is from a
   * client it signals Send.sendDone(); if it is a forwarded packet it returns
   * the packet and queue entry to their respective pools.
   * 
   */
	void packetComplete(fwd_queue_entry_t * qe, message_t * msg, bool success) {
		// Four cases:
		// Local packet: success or failure
		// Forwarded packet: success or failure
		if(success) {
			/*dbg("CtpForwarder",
					"%s: forwarded packet %hu.%hhu acknowledged: insert in transmit queue.\n",
					__FUNCTION__, 
					call CollectionPacket.getOrigin(msg), 
					call CollectionPacket.getSequenceNumber(msg));
			call CollectionDebug.logEventMsg(NET_C_FE_FWD_MSG, 
					call CollectionPacket.getSequenceNumber(msg), 
					call CollectionPacket.getOrigin(msg),
					call AMPacket.destination(msg));*/
		}
		else {
			/*dbg("CtpForwarder", "%s: forwarded packet %hu.%hhu dropped.\n",
					__FUNCTION__, call CollectionPacket.getOrigin(msg), 
					call CollectionPacket.getSequenceNumber(msg));
			call CollectionDebug.logEventMsg(NET_C_FE_SENDDONE_FAIL_ACK_FWD,
					call CollectionPacket.getSequenceNumber(msg), 
					call CollectionPacket.getOrigin(msg), 
					call AMPacket.destination(msg));*/
					
			// ph4r05 		
			// packet dropped - re-Beacon here
			//call CtpInfo.triggerRouteUpdate();
		}
		if(call MessagePool.put(qe->msg) != SUCCESS) 
			pl_log_w(TAG, "MsgPoolErr\n"); //call CollectionDebug.logEvent(NET_C_FE_PUT_MSGPOOL_ERR);
		if(call QEntryPool.put(qe) != SUCCESS) 
			pl_log_w(TAG, "QEntryPoolErr\n"); //call CollectionDebug.logEvent(NET_C_FE_PUT_QEPOOL_ERR);
		
	}
  
  event void SubSend.sendDone(message_t* msg, error_t error) {
    fwd_queue_entry_t *qe = call SendQueue.head();
    //am_addr_t dest = call UnicastNameFreeRouting.nextHop();
    //dbg("Forwarder", "%s to %hu and %hhu\n", __FUNCTION__, call AMPacket.destination(msg), error);

    if (error != SUCCESS) {
      /* The radio wasn't able to send the packet: retransmit it. */
      dbg("Forwarder", "%s: send failed\n", __FUNCTION__);
      pl_log_d(TAG, "SendDone[%p]: Failed err=%u\n", msg, error);
      /*call CollectionDebug.logEventMsg(NET_C_FE_SENDDONE_FAIL, 
				       call CollectionPacket.getSequenceNumber(msg), 
				       call CollectionPacket.getOrigin(msg), 
				       call AMPacket.destination(msg));*/
      startRetxmitTimer(SENDDONE_FAIL_WINDOW_X, SENDDONE_FAIL_OFFSET_X);
      //signal CtpForwardingSubSendDone.CTPSubSendDone(msg, error, qe, dest, FALSE);
    }
    /*else if (hasState(ACK_PENDING) && !call PacketAcknowledgements.wasAcked(msg)) {
      // No ack: if countdown is not 0, retransmit, else drop the packet. 
      signal CtpForwardingSubSendDone.CTPSubSendDone(msg, SUCCESS, qe, dest, FALSE); // signal it now, before state changes
      
      //call LinkEstimator.txNoAck(call AMPacket.destination(msg));
      //call CtpInfo.recomputeRoutes();
      if (--qe->retries) { 
        dbg("Forwarder", "%s: not acked, retransmit\n", __FUNCTION__);
        //call CollectionDebug.logEventMsg(NET_C_FE_SENDDONE_WAITACK, 
		//			 call CollectionPacket.getSequenceNumber(msg), 
		//			 call CollectionPacket.getOrigin(msg), 
        //                                 call AMPacket.destination(msg));
        startRetxmitTimer(SENDDONE_NOACK_WINDOW, SENDDONE_NOACK_OFFSET);
      } else {
		// Hit max retransmit threshold: drop the packet. 
		call SendQueue.dequeue();
        clearState(SENDING);
        startRetxmitTimer(SENDDONE_OK_WINDOW, SENDDONE_OK_OFFSET);
	
		packetComplete(qe, msg, FALSE);
      }
    }*/
    else {
      /* Packet was acknowledged. Updated the link estimator,
	 free the buffer (pool or sendDone), start timer to
	 send next packet. */
	  //signal CtpForwardingSubSendDone.CTPSubSendDone(msg, SUCCESS, qe, dest, TRUE); // signal it now, before state changes
	 
      call SendQueue.dequeue();
      clearState(SENDING);
      startRetxmitTimer(SENDDONE_OK_WINDOW_X, SENDDONE_OK_OFFSET_X);
      //call LinkEstimator.txAck(call AMPacket.destination(msg));
      packetComplete(qe, msg, TRUE);
      
      pl_log_d(TAG, "SendDone[%p]: SUCCESS\n", msg);
    }
  }

  /*
   * Function for preparing a packet for forwarding. Performs
   * a buffer swap from the message pool. If there are no free
   * message in the pool, it returns the passed message and does not
   * put it on the send queue.
   */
  message_t* ONE forward(message_t* ONE m, uint8_t len) {
  	
  	// null check ph4r05
	if (m == NULL){
	  	// log null message - something went wrong
	  	pl_log_w(TAG, "Empty message");
	  	return m;
	}
	    
    if (call MessagePool.empty()) {
      dbg("Route", "%s cannot forward, message pool empty.\n", __FUNCTION__);
      // send a debug message to the uart
      //call CollectionDebug.logEvent(NET_C_FE_MSG_POOL_EMPTY);
      pl_log_w(TAG, "MsgPoolEmpty\n");
    }
    else if (call QEntryPool.empty()) {
      dbg("Route", "%s cannot forward, queue entry pool empty.\n", __FUNCTION__);
      // send a debug message to the uart
      //call CollectionDebug.logEvent(NET_C_FE_QENTRY_POOL_EMPTY);
      pl_log_w(TAG, "QEntryPoolEmpty\n");
    }
    else {
      message_t* newMsg;
      fwd_queue_entry_t *qe;
      //uint16_t gradient;
      
      qe = call QEntryPool.get();
      if (qe == NULL) {
        //call CollectionDebug.logEvent(NET_C_FE_GET_MSGPOOL_ERR);
        pl_log_w(TAG, "QEntryPoolError\n");
        
        return m;
      }

      newMsg = call MessagePool.get();
      if (newMsg == NULL) {
        //call CollectionDebug.logEvent(NET_C_FE_GET_QEPOOL_ERR);
        pl_log_w(TAG, "MessagePoolError\n");
        
        return m;
      }

      memset((void*)newMsg, 0, sizeof(message_t));
      memset((void*)(m->metadata), 0, sizeof(message_metadata_t));
      
      qe->msg = m;
      qe->client = 0xff;
      qe->retries = FWDER_MAX_RETRIES;
      qe->len = len;
            
      if (call SendQueue.enqueue(qe) == SUCCESS) {
        dbg("Forwarder,Route", "%s forwarding packet %p with queue size %hhu\n", __FUNCTION__, m, call SendQueue.size());
        
        if (!call RetxmitTimer.isRunning()) {
          // sendTask is only immediately posted if we don't detect a
          // loop.
	  	  dbg("FHangBug", "%s: posted sendTask.\n", __FUNCTION__);
          post sendTask();
        }
        
        // Successful function exit point:
        return newMsg;
      } else {
        // There was a problem enqueuing to the send queue.
        if (call MessagePool.put(newMsg) != SUCCESS)
          pl_log_w(TAG, "MsgPoolErr\n"); //call CollectionDebug.logEvent(NET_C_FE_PUT_MSGPOOL_ERR);
        if (call QEntryPool.put(qe) != SUCCESS)
          pl_log_w(TAG, "QEntryPoolErr\n"); //call CollectionDebug.logEvent(NET_C_FE_PUT_QEPOOL_ERR);
      }
    }

    // NB: at this point, we have a resource acquistion problem.
    // Log the event, and drop the
    // packet on the floor.
    //call CollectionDebug.logEvent(NET_C_FE_SEND_QUEUE_FULL);
    pl_log_w(TAG, "SendQueueFull\n");
    
    return m;
  }
 
  /*
   * Received a message to forward. 
   */ 
  event message_t * Receive.receive(message_t * msg, void * payload, uint8_t len) {

		pl_log_d(TAG, "Forwarder Receive.receive called.\n"); 
		if(len > call SubSend.maxPayloadLength()) {
			// ph4r05
			pl_log_d(TAG, "Too long\n"); 
			return msg;
		}
		
		return forward(msg, len);		
	}
	
  event void RetxmitTimer.fired() {
    clearState(SENDING);
    post sendTask();
  }
  void clearState(uint8_t state) {
    forwardingState = forwardingState & ~state;
  }
  bool hasState(uint8_t state) {
    return forwardingState & state;
  }
  void setState(uint8_t state) {
    forwardingState = forwardingState | state;
  }
#else
	command error_t Init.init(){
		return SUCCESS;
	}
#endif
}

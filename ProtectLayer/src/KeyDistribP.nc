/** 
 *  Component providing implementation of KeyDistrib interface.
 *  A module providing actual implementation of Key distribution component.
 * 	@version   0.1
 * 	@date      2012-2013
 */
 #include "ProtectLayerGlobals.h"
#include "printf.h"

module KeyDistribP{
	/*@{*/
	uses {
		interface Crypto; /**< Crypto interface is used */
        interface SharedData;
        interface Privacy;
        //interface Random;  //for challenge generation
           
        interface AMSend; //temporarily just for testing purposes
        interface Receive; //temporarily just for testing purposes
        interface Packet;
    	interface AMPacket;
	}
	provides {
		interface Init; /**< Init interface is provided to initialize component on startup */
		interface KeyDistrib; /**< KeyDistrib interface is provided */
	}
	/*@}*/
}
implementation{
        uint8_t m_currentNodeIndex; /**< index of current node processed pointing to m_neighborsID - used in recurrent tasks to identify index of node next to be processed */
        //uint8_t m_lastNodeIndex;    /**< index of last value set in m_neighborsID */
        //uint8_t m_neighborsID[MAX_NEIGHBOR_COUNT]; /**< array of neighbors IDs - use for lookup into shared data structures */
	uint16_t m_state;			/**< current state of the component - used to decice on next step inside task */
	PL_key_t m_keyToBS;			/**< handle to key shared with base station */ 
	uint8_t  m_getKeyToNodeID;  /**< ID of node from which getKeyToNode command was issued */
        //PL_key_t m_keysToNodes[MAX_NEIGHBOR_COUNT]; /**< handles to keys shared with separate neighbors */
      
        
	uint8_t challengeLength = 8; 
	uint8_t challenge[challengeLength];	 
	uint8_t key[8];
	typedef nx_struct{		
		nx_uint8_t challenge[16];
	} challengeMessage;
	message_t pkt;
	uint8_t hashLength = 32;
	
	typedef enum state {
		INITIAL = 0,
		CHALLENGE_GENERATED = 1,
		CHALLENGE_SENT = 2,
		KEYS_GENERATED = 3
		
	} state;
	
	uint8_t currentState;
	//
	//	KeyDistrib interface
	//
	/**
		Task: Performs key discovery among direct neighbours. This task repost itself until last node is processed
		Signal: KeyDistrib.discoverKeysDone
		@return nothing
	*/	
	task void task_discoverKeys() {
            error_t status = SUCCESS;
            error_t tmpStatus = SUCCESS;
            SavedData_t*    pSavedData = NULL;
            KDCPrivData_t*  kdcPrivData = NULL;
            uint8_t i;
            
			message_t* msg;
			
            PrintDbg("KeyDistribP", "KeyDistrib.task_discoverKeys called.\n");
/*
            // BUGBUG: simulation of key discovery: key value is formed as X|Y where X and Y are nodeIDs of two neighbours.
            // First part (X) is lower ID, Y is higher ID (so that task_discoverKeys on pair node will result in same key value)
            pSavedData = call SharedData.getSavedData();
            for (i = 0; i < MAX_NEIGHBOR_COUNT; i++) {
                if (pSavedData[i].nodeId > 0) {
                    //TODO: we should call Crypto.generateKey(&(pSavedData[i].kdcData.shared_key)); and wait for generation of new key
                    if ((tmpStatus = call Crypto.generateKeyBlocking(&(pSavedData[i].kdcData.shared_key))) == SUCCESS) {
                        pSavedData[i].kdcData.shared_key.keyType = KEY_TONODE;
                        pSavedData[i].kdcData.shared_key.keyValue[0] = (pSavedData[i].nodeId < TOS_NODE_ID) ? pSavedData[i].nodeId : TOS_NODE_ID;
                        pSavedData[i].kdcData.shared_key.keyValue[1] = (pSavedData[i].nodeId < TOS_NODE_ID) ? TOS_NODE_ID : pSavedData[i].nodeId;
                    }
                    else {
                        PrintDbg("KeyDistribP", "KeyDistrib.task_discoverKeys failed to generate new key for node  .\n", pSavedData[i].nodeId);
                        status = ENOTALLKEYSDISCOVERED;
                    }
                }
            }

            // Create key to BS
            kdcPrivData = call SharedData.getKDCPrivData();
            if ((tmpStatus = call Crypto.generateKeyBlocking(&(kdcPrivData->keyToBS))) == SUCCESS) {
                kdcPrivData->keyToBS.keyType = KEY_TOBS;
                kdcPrivData->keyToBS.keyValue[0] = TOS_NODE_ID;
                kdcPrivData->keyToBS.keyValue[1] = 0xff;
            }
            else {
                PrintDbg("KeyDistribP", "KeyDistrib.task_discoverKeys failed to generate new key for BS.\n");
                status = ENOTALLKEYSDISCOVERED;
            }


            signal KeyDistrib.discoverKeysDone(status);
*/
 //THIS IS BETTER VERSION WITH SEPARATE TASK FOR EVERY NODE
                    PrintDbg("KeyDistribP", "KeyDistrib.task_discoverKeys for node '%d' called.\n", m_currentNodeIndex);
                // TODO: initiate discovery
		// We will have multiple nodes, make task for every separate node
		// for_each neigh_node post task process
		
		//challenge should be already generated, if not, repost init 
		if (currentState != CHALLENGE_GENERATED ){
			PrintDbg("KeyDistribP", "Challenge not generated, repeating Init");
			call Init.init();	
		}
            if (m_currentNodeIndex < MAX_NEIGHBOR_COUNT) {
            	if(!(call Privacy.getBusy())){
            		challengeMessage* msg = (challengeMessage*)(call Packet.getPayload(&pkt, sizeof(challengeMessage)));
					memcpy(msg->challenge, challenge, challengeLength);		
					if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(challengeMessage)) == SUCCESS) {
       					call Privacy.setBusy(TRUE);
       					currentState = CHALLENGE_SENT;
       				}					
				}					
                    // repost task to process next node                   
                    m_currentNodeIndex++;
                    post task_discoverKeys();
		}
        if (m_currentNodeIndex == MAX_NEIGHBOR_COUNT) {
        	// we are done
        	m_state &= ~FLAG_STATE_KDP_DISCOVERKEYS;
        	//TODO: remember status results from all keys
        	signal KeyDistrib.discoverKeysDone(SUCCESS);
        }

   	}        
	
	/*
    // Method DeriveKey derives key from provided master key.
    // KDF is a deterministic algorithm to derive a key of a given size from 
    // a single master key. Implementation was done according to following 
    // documentation: http://csrc.nist.gov/publications/nistpubs/800-108/sp800-108.pdf.
    // <param name="key">Master key</param>
    // <param name="label">Identifies the purpose for the derived key</param>
    // <param name="context">Containing information related to the derived key</param>
    // <param name="derivedKeyLength">Length of derived key (bits)</param>
    // <returns>Derived key</returns>
	uint8_t* deriveKey(uint8_t* key, uint8_t label[keyLabelLength], uint8_t context[challengeLength * 2], int16_t derivedKeyLength){
		uint16_t const h = 256; //length of the output of the PRF (HMACSHA256 - 32 bytes) in bits 
		uint8_t const separationIndicator = 0x00; // separation indicator
		//exceptions skipped
		int32_t n = (derivedKeyLength + (h - 1)) / h;
		int32_t x;
		uint8_t K_i[hashLength];
		uint8_t result_i[n * hashLength];
		uint8_t data[1 + keyLabelLength + 1 + (challengeLength * 2) + 2];
		uint8_t i;
		
		// copy arrays to data in order: Label, sep., context, sep., + at two last add derived key length
		for (i = 0; i < keyLabelLength; i++){
			data[i] = label[i];	
		}
		data[keyLabelLength] = separationIndicator;
		for (i = 0; i < challengeLength * 2; i++){
			data[i + keyLabelLength +1] = context[i];
		}
		data[keyLabelLength + challengeLength * 2 + 1] = separationIndicator;
		data[keyLabelLength + challengeLength * 2 + 2] = (uint8_t)(derivedKeyLength >> 8);
        data[keyLabelLength + challengeLength * 2 + 3] = (uint8_t)derivedKeyLength;	
        
        for (x = 1; x <= n; x++){
        	data[0] = (uint8_t)x;
            K_i = ComputeHash(key, data);

			for (i = 0; i < hashLength; i++){
				result_i[((x - 1) * hashLength) + i] = K_i[i];
			}			            
        }
        
        uint8_t K_0[derivedKeyLength / 8];
        for (i = 0; i < (derivedKeyLength / 8); i++){
        	K_0[i] = result_i[i];
        }	
        return K_0;
	}
*/	
	
	/**
		Command: Posts taks for key task_discoverKeys for key discovery
		@return error_t status. SUCCESS or EALREADY if already pending
	*/	
	command error_t KeyDistrib.discoverKeys() {
                PrintDbg("KeyDistribP", "KeyDistrib.discoverKeys called.\n");
		if (m_state & FLAG_STATE_KDP_DISCOVERKEYS) {
			return EALREADY;	
		}
		else {
			// Change state to discovery and post task to process first node
			m_state |= FLAG_STATE_KDP_DISCOVERKEYS;
			m_currentNodeIndex = 0;
			post task_discoverKeys();
			return SUCCESS;
		}
	}
	/**
		Event: Default handler for KeyDistrib.discoverKeysDone event
		@param error_t status returned by task_discoverKeys task
		@return nothing
	*/	
	default event void KeyDistrib.discoverKeysDone(error_t result) {}
	
	/**
		Task: Returns handle to key shared between node and base station
		Signal: KeyDistrib.getKeyToBSDone
		@return nothing
	*/	
	task void task_getKeyToBS() {
                PrintDbg("KeyDistribP", "KeyDistrib.task_getKeyToBS called.\n");
		m_state &= ~FLAG_STATE_KDP_GETKEYTOBS;
		signal KeyDistrib.getKeyToBSDone(SUCCESS, &m_keyToBS);
	}
	/**
		Command: Posts taks task_getKeyToBS for obtaining key to base station
		@return error_t status. SUCCESS or EALREADY if already pending
	*/	
	command error_t KeyDistrib.getKeyToBS() {
                PrintDbg("KeyDistribP", "KeyDistrib.getKeyToBS called.\n");
		if (m_state & FLAG_STATE_KDP_GETKEYTOBS) {
			return EALREADY;	
		}
		else {
			m_state |= FLAG_STATE_KDP_GETKEYTOBS;
			post task_getKeyToBS();
			return SUCCESS;
		}
	}
	/**
		Event: Default handler for KeyDistrib.getKeyToBSDone event
		@param resultreturned by task_getKeyToBS
		@param pBSKey handle to key shared between node and base station
		@return nothing
	*/	
	default event void KeyDistrib.getKeyToBSDone(error_t result, PL_key_t* pBSKey) {}

	/**
		Task: Returns handle to key shared between this node and other node specified by nodeID
		Signal: KeyDistrib.getKeyToNodeDone
		@return nothing
	*/	
	task void task_getKeyToNode() {
        // todo: call getKeyToNodeB
            SavedData_t* pSavedData = NULL;
            PrintDbg("KeyDistribP", "KeyDistrib.task_getKeyToNode called.\n");
            m_state &= ~FLAG_STATE_KDP_GETKEYTONODE;
            pSavedData = call SharedData.getNodeState(m_getKeyToNodeID);

            if (pSavedData != NULL) {
                signal KeyDistrib.getKeyToNodeDone(SUCCESS, &(pSavedData->kdcData.shared_key));
            }
            else {
                 PrintDbg("KeyDistribP", "Failed to obtain SharedData.getNodeState.\n");
                signal KeyDistrib.getKeyToNodeDone(EKEYNOTFOUND, NULL);
            }
        }

	/**
		Command: Posts task task_getKeyToNode for obtaining handle to key shared between this node and other node specified by nodeID
		@return error_t status. SUCCESS or EALREADY if already pending
	*/	
	command error_t KeyDistrib.getKeyToNode(uint8_t nodeID) {
                PrintDbg("KeyDistribP", "KeyDistrib.getKeyToNode(%d) called.\n", nodeID);
		if (m_state & FLAG_STATE_KDP_GETKEYTONODE) {
			return EALREADY;	
		}
		else {
			m_getKeyToNodeID = nodeID;
			m_state |= FLAG_STATE_KDP_GETKEYTONODE;
			post task_getKeyToNode();
			return SUCCESS;
		}
	}
	/**
		Event: Default handler for KeyDistrib.getKeyToNodeDone event
		@param result returned by task_getKeyToNode
		@param pNodeKey handle to key shared between this node and specified node
		@return nothing
	*/	
	default event void KeyDistrib.getKeyToNodeDone(error_t result, PL_key_t* pNodeKey) {}

	
	command PL_key_t* KeyDistrib.getKeyToNodeB(uint8_t nodeID) {
            SavedData_t* pSavedData = NULL;
            //PrintDbg("KeyDistribP", "KeyDistrib.getKeyToNodeB called for node '%d' .\n", nodeID);

            pSavedData = call SharedData.getNodeState(nodeID);
            if (pSavedData != NULL) {
                //PrintDbg("KeyDistribP", "Shared key returned.\n");
                return &(pSavedData->kdcData.shared_key);
            }
            else {
                PrintDbg("KeyDistribP", "Failed to obtain SharedData.getNodeState.\n");
                return NULL;
            }
	}





	//
	// Crypto interface
	//		
	/**
		Event handler for Crypto.encryptBufferDone event
	*/	
	event void Crypto.encryptBufferDone(error_t status, uint8_t* buffer, uint8_t resultLen) {}
	/**
		Event handler for Crypto.decryptBufferDone event
	*/	
	event void Crypto.decryptBufferDone(error_t status, uint8_t* buffer, uint8_t resultLen) {}
	/**
		Event handler for Crypto.deriveKeyDone event
	*/	
	event void Crypto.deriveKeyDone(error_t status, PL_key_t* derivedKey) {}
	/**
		Event handler for Crypto.generateKeyDone event
	*/	
	event void Crypto.generateKeyDone(error_t status, PL_key_t* newKey) {}



        //
        //	Init interface
        //
        /**
                Command: Perform initialization of KeyDistribP component (should be called only once after reset)
                @todo if internal state was already established (only reset occured), initializtion should load values from shared memory
                @return error_t status. SUCCESS only
        */
        command error_t Init.init() {
                uint8_t i = 0;
                PrintDbg("KeyDistribP", "KeyDistribP.Init.init() entered");

                // TODO: do other initialization
                // listen for initialization from other nodes 
                currentState = INITIAL;
                m_state = 0;
                
				//generate challenge
				PrintDbg("KeyDistribP", "generating challenge");
				if (call Crypto.generateRandomData(challenge, 0, challengeLength) != SUCCESS){
					PrintDbg("KeyDistribP", "challenge generator failed, init repeat");
					call Init.init();
					return FAIL;
				} 
				currentState = CHALLENGE_GENERATED;
				
				call KeyDistrib.discoverKeys();

                // m_keyToBS initialization
                m_keyToBS.keyType = KEY_TOBS;
                for (i = 0; i < KEY_LENGTH; i++) m_keyToBS.keyValue[i] = 0;
                return SUCCESS;
        }
        
	//temporarily added for testing  purposes
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		if (len == sizeof(challengeMessage)){
			PrintDbg("KeyDistribP", "message received");
			challengeMessage* challMsg = (challengeMessage*) payload;
			uint8_t i;
			switch(currentState){
				case INITIAL: {
					PrintDbg("KeyDistribP", "wrong state, cannot receive message in initial state");
					break;	
				}
				case CHALLENGE_GENERATED: {
					PrintDbg("KeyDistribP", "received challenge, generating keys");
					for (i = 0; i < 8; i++){
						//xor values
						key[i] = challenge[i] ^ challMsg->challenge[i];								
					}
					currentState = KEYS_GENERATED;
					PrintDbg("KeyDistribP","key generated: " + key);
					//sent back
					if(!(call Privacy.getBusy())){
            			challengeMessage* msg = (challengeMessage*)(call Packet.getPayload(&pkt, sizeof(challengeMessage)));
						memcpy((msg->challenge) + challengeLength, challenge, challengeLength);		
						if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(challengeMessage)) == SUCCESS) {
       						call Privacy.setBusy(TRUE);
       						currentState = CHALLENGE_GENERATED;
       					}					
					}
					break;										
				}	
				case CHALLENGE_SENT: {
					PrintDbg("KeyDistribP", "received challenge response, generating keys");
					for (i = 0; i < 8; i++){
						//xor values
						key[i] = challMsg->challenge[i] ^ challMsg->challenge[i + challengeLength];
						currentState = KEYS_GENERATED;
						PrintDbg("KeyDistribP","key generated: " + key);								
					}
					currentState = CHALLENGE_GENERATED;
					break;
				}
				//add case for challenge sent 
			}
		}
		return msg;
	}

	event void AMSend.sendDone(message_t *msg, error_t error){
		if(error = FAIL){
			currentState = CHALLENGE_GENERATED;
		}
		call Privacy.setBusy(FALSE);
	}
}

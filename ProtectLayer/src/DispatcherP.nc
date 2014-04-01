#include "ProtectLayerGlobals.h"

module DispatcherP {
	uses {
#ifndef THIS_IS_BS 
		interface Receive as Lower_PL_Receive;
		interface Receive as Lower_ChangePL_Receive;
		interface Receive as Lower_IDS_Receive;
#endif
		interface Packet;
		//interface Init as CryptoCInit;	
		interface Init as PrivacyCInit;
		interface Init as SharedDataCInit;
		interface Init as IntrusionDetectCInit;
		interface Init as KeyDistribCInit;
		interface Init as PrivacyLevelCInit;
		interface Init as RouteCInit;
		//interface Init as ForwarderCInit;
		//interface Init as PrivacyLevelCInit;
		interface Boot;
		interface Privacy;
		interface MagicPacket;
		interface SharedData;
		interface ResourceArbiter;
	}
	provides {
		interface Receive as PL_Receive;
		interface Receive as IDS_Receive;
		interface Receive as ChangePL_Receive;
		interface Init;
		interface Receive as Sniff_Receive;
		interface Dispatcher;
	}
}
implementation {

	message_t memoryMsgForIDS;
	message_t * p_msgForIDS;

	// Logging tag for this component
	static const char * TAG = "DispatcherP";

	command error_t Init.init() {
		p_msgForIDS = &memoryMsgForIDS;
		return SUCCESS;
	}

	event void Boot.booted() {

	}

	
#ifndef THIS_IS_BS 
	void passToIDS(message_t * msg, void * payload, uint8_t len) {
		if(msg == NULL || payload == NULL) {
			pl_log_e(TAG, "pass2IDS ERR null\n");
			return;
		}

		// copy message content to IDS msg
		memcpy(p_msgForIDS, msg, sizeof(message_t));

		// signal to IDS and update memory field for next msg
		p_msgForIDS = signal Sniff_Receive.receive(p_msgForIDS, call Packet
				.getPayload(p_msgForIDS, len), len);

	}

	event message_t * Lower_ChangePL_Receive.receive(message_t * msg, void 
			* payload, uint8_t len) {
		if((call SharedData.getAllData())->dispatcherState < STATE_READY_TO_DEPLOY) {
			return msg;
		}

		//Pass copy of message to IDS
		// IDS is not processing messages for changing privacy level
		//passToIDS(msg, payload, len); 

		return signal ChangePL_Receive.receive(msg, payload, len);
	}

	event message_t * Lower_IDS_Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
		if((call SharedData.getAllData())->dispatcherState < STATE_READY_FOR_APP) {
			return msg;
		}

		//Pass copy of message to IDS
		passToIDS(msg, payload, len);

		return signal IDS_Receive.receive(msg, payload, len);
	}

	event message_t * Lower_PL_Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
		if((call SharedData.getAllData())->dispatcherState < STATE_READY_FOR_APP) {
			return msg;
		}

		return signal PL_Receive.receive(msg, payload, len);
	}
#endif

	// In BS mode no message will be received directly from the radio in this component.
	// Initialization routine also differs. 
	command void Dispatcher.serveState() {
		uint8_t * pState = &((call SharedData.getAllData())->dispatcherState);
		
		pl_log_i(TAG, "<serveState(%x)>\n", *pState);
		switch(*pState) {
			case STATE_INIT : {
				//init shared data
				//BUGBUG not blocking
				call SharedDataCInit.init();

				*pState = STATE_INIT_IN_PROGRESS;
				//*pState = transitionTable[*pState];
				break;
			}
			case STATE_LOADED_FROM_EEPROM : {
				//crypto init = auto init 

				//init privacy level, BLOCKING			
				call PrivacyLevelCInit.init();

				//privacy init, BLOCKING
				call PrivacyCInit.init(); //mem init
				//Forwarder init = auto init 

				//IDS init, BLOCKING
				call IntrusionDetectCInit.init();
				//PrivacyLevel init = auto init 

#ifdef THIS_IS_BS 
				// Signalize to the ProtectLayer that initialization is
				// completed. PL will pass this information to the application.
				// 
				// In basestation mode, further initialization is responsibility of the app.
				// 
				call Privacy.startApp(SUCCESS);
#endif

				*pState = STATE_READY_TO_DEPLOY;
				//*pState = transitionTable[*pState];
				
				
				//BUGBUG no break!!! break; IF enabled, waiting for magic packet will be done
				
#ifdef THIS_IS_BS
				break;
#endif
			}
			case STATE_READY_TO_DEPLOY : {
#ifdef THIS_IS_BS
				//no code
#else
				//BUGBUG if serve state called and magic packet not received (assumption, now is serve state called only if magic packet arrived)
				// MAGIC PAKET - PrivacyLevel signalized received magic packet.
				//*pState = transitionTable[*pState];
				*pState = STATE_MAGIC_RECEIVED;
				

				pl_log_d(TAG, "<waitingForPacket>\n");
				pl_printfflush();

#ifdef SKIP_MAGIC_PACKET
				pl_log_d(TAG, "<magicPacketSkipped>\n");
#else
				break;
#endif
#endif
			}
			case STATE_MAGIC_RECEIVED : {
				pl_log_d(TAG, "MP received. Going to init RouteP\n");

				// Init Routing component
				call RouteCInit.init();
				
				*pState = STATE_ROUTES_IN_PROGRESS;
				
				break;				
			}
			case STATE_ROUTES_READY : {
				pl_log_d(TAG, "Route initialized. Going to init KeyDistribP\n");
				// init key distribution component
				call KeyDistribCInit.init();
				
				*pState = STATE_KEYDISTRIB_IN_PROGRESS;
				//*pState = STATE_READY_FOR_SAVE;
				
				break;				
			}
			case STATE_READY_FOR_SAVE : {
				// Save actualized shared data 
				
				//WARNING: state changed to STATE_READY_FOR_APP, so that this state will be saved to EEPROM
				*pState = STATE_READY_FOR_APP;
				call ResourceArbiter.saveCombinedDataToFlash();
				
				

				break;
			}
			case STATE_READY_FOR_APP : {
#ifdef THIS_IS_BS
				//no code
#else

				*pState = STATE_WORKING;
				
				//BUGBUG no break!!! break;
#endif
			}

			case STATE_WORKING : {
				*pState = STATE_WORKING;

#ifndef THIS_IS_BS
				// Signalize to the ProtectLayer that initialization is
				// completed. PL will pass this information to the application.
				// 
				call Privacy.startApp(SUCCESS);
#endif
				
				break;
			}
			default :{
				pl_log_e(TAG, "state %x not explicitly served\n", *pState);
			}
		}

		pl_log_d(TAG, "</serveState(%x)>\n", *pState);
		pl_printfflush();
	}
	
	command void Dispatcher.stateFinished(uint8_t finishedState){
	
	    uint8_t * pState = &((call SharedData.getAllData())->dispatcherState);
	    pl_log_d(TAG, "stateFinished(%x) called\n", *pState);

	    if(*pState == finishedState){
	        switch(finishedState){
		    case STATE_ROUTES_IN_PROGRESS: {
			*pState = STATE_ROUTES_READY;
			break;
		    }
		    case STATE_KEYDISTRIB_IN_PROGRESS: {
			*pState = STATE_READY_FOR_SAVE;
			break;
		    }
		    case STATE_SAVE_IN_PROGRESS:{
			*pState = STATE_READY_FOR_APP;
			break;
		    }
		    default: {
			pl_log_f(TAG, "state %x not defined in stateFinished event\n", *pState);
			return;
		    }
		
	        }        
	        
		call Dispatcher.serveState();
	    } else {
		pl_log_e(TAG, "current state %x signalized finished state %x, not matched \n", *pState, finishedState);
	    }
	    
	}
	

#ifndef THIS_IS_BS
	task void serveStateTask() {
		call Dispatcher.serveState();
	}
#endif

	event void MagicPacket.magicPacketReceived(error_t status,
			PRIVACY_LEVEL newPrivacyLevel) {
#ifdef THIS_IS_BS
		//no code
		// Magic packet not relevant if BS, we are producing magic packet!
#else
		pl_log_i(TAG, "magicPacket received\n");
#ifndef SKIP_MAGIC_PACKET
		post serveStateTask();
#endif
#endif
	}

	event void ResourceArbiter.saveCombinedDataToFlashDone(error_t result) {
		pl_log_d(TAG, "saveCombinedDataToFlashDone.\n");
		call Dispatcher.serveState();
	}

	event void ResourceArbiter.restoreCombinedDataFromFlashDone(error_t result) {
		pl_log_d(TAG, "restoreCombinedDataFromFlashDone.\n");
		call Dispatcher.serveState();
	}

	event void ResourceArbiter.restoreKeyFromFlashDone(error_t result) {
		pl_log_d(TAG, "restoreKeyFromFlashDone.\n");
	}
}
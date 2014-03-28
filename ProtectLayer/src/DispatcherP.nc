#include "ProtectLayerGlobals.h"

module DispatcherP{
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
implementation{
    
    message_t memoryMsgForIDS;
    message_t * p_msgForIDS;
    
    uint8_t m_state = STATE_INIT;
    
    // Logging tag for this component
    static const char *TAG = "DispatcherP";
    
    
    
    command error_t Init.init() {
        p_msgForIDS = &memoryMsgForIDS;		
        return SUCCESS;
    }
    
    event void Boot.booted() {
        
    }
    
    default event void Dispatcher.stateChanged(uint8_t newState){
    	
    }
    
#ifndef THIS_IS_BS	
    void passToIDS(message_t* msg, void* payload, uint8_t len){
        if (msg==NULL || payload==NULL){
        	pl_log_e(TAG, "pass2IDS ERR null\n");
        	return;
        }
        
        // copy message content to IDS msg
        memcpy(p_msgForIDS,msg,sizeof(message_t));
        
        // signal to IDS and update memory field for next msg
        p_msgForIDS = signal Sniff_Receive.receive(p_msgForIDS, call Packet.getPayload(p_msgForIDS, len), len);
        
    }
    
    
    event message_t * Lower_ChangePL_Receive.receive(message_t *msg, void *payload, uint8_t len){
        if (m_state<STATE_READY_TO_DEPLOY){
        	return msg;
        }
        
        //Pass copy of message to IDS
        // IDS is not processing messages for changing privacy level
        //passToIDS(msg, payload, len);
        
        return signal ChangePL_Receive.receive(msg, payload, len);
    }
    
    event message_t * Lower_IDS_Receive.receive(message_t *msg, void *payload, uint8_t len){
        if (m_state<STATE_READY_FOR_APP){
        	return msg;
        }
        
        //Pass copy of message to IDS
        passToIDS(msg, payload, len);
        
        return signal IDS_Receive.receive(msg, payload, len);
    }
    
    
    event message_t * Lower_PL_Receive.receive(message_t *msg, void *payload, uint8_t len){
        if (m_state<STATE_READY_FOR_APP){
        	return msg;
        }
        
        return signal PL_Receive.receive(msg, payload, len);
    }

    command void Dispatcher.serveState() {

        pl_log_i(TAG, "<serveState(%x)>\n", m_state); 

        switch (m_state) {
        case STATE_INIT:
        {
            //init shared data
            call SharedDataCInit.init();
            //crypto init = auto init
            
            //init privacy level
            call PrivacyLevelCInit.init();
            
            //privacy init
            call PrivacyCInit.init();  //mem init
            //Forwarder init = auto init
            
            //IDS init
            call IntrusionDetectCInit.init();
            //PrivacyLevel init = auto init
            
            m_state = STATE_READY_TO_DEPLOY;
            signal Dispatcher.stateChanged(m_state);
            
            //BUGBUG no break!!! break;
        }
        case STATE_READY_TO_DEPLOY:
        {            
            // Wait for MAGIC PAKET - PrivacyLevel will signalize received magic packet.
            m_state = STATE_MAGIC_RECEIVED;
            signal Dispatcher.stateChanged(m_state);
            
            pl_log_d(TAG, "<waitingForPacket>\n"); 
            pl_printfflush();
            
#ifdef SKIP_MAGIC_PACKET
            pl_log_d(TAG, "<magicPacketSkipped>\n");
#else
            break;            
#endif
        }
        case STATE_MAGIC_RECEIVED:
        {
        	pl_log_d(TAG, "MP received. Going to init RouteP\n"); 
        	
        	// Init Routing component
        	call RouteCInit.init();
        	
        	pl_log_d(TAG, "Route initialized. Going to init KeyDistribP\n"); 
            // init key distribution component
            call KeyDistribCInit.init();
            
            // Save actualized shared data 
            call ResourceArbiter.saveCombinedDataToFlash();
            
            m_state = STATE_READY_FOR_APP;
            signal Dispatcher.stateChanged(m_state);
           

            break;
        }
        case STATE_READY_FOR_APP:
        {
         
            
            m_state = STATE_WORKING;
            signal Dispatcher.stateChanged(m_state);
            
            //BUGBUG no break!!! break;
        }			
            
        case STATE_WORKING:
        {
            m_state = STATE_WORKING;
            
            // Signalize to the ProtectLayer that initialization is
            // completed. PL will pass this information to the application.
            // 
            call Privacy.startApp(SUCCESS);
            signal Dispatcher.stateChanged(m_state);
            
            break;
        }
        }

        pl_log_d(TAG, "</serveState(%x)>\n", m_state); 
        pl_printfflush();
    }
    
    task void serveStateTask(){
    	call Dispatcher.serveState();
    }
    
    event void MagicPacket.magicPacketReceived(error_t status, PRIVACY_LEVEL newPrivacyLevel){
    	pl_log_i(TAG, "magicPacket received\n"); 
#ifndef SKIP_MAGIC_PACKET
    	post serveStateTask();
#endif
    }
#else
	// Here node is BS!
	// In BS mode no message will be received directly from the radio in this component.
	// Initialization routine also differs. 
	command void Dispatcher.serveState() {

        pl_log_i(TAG, "<serveState(%x)>\n", m_state); 

        switch (m_state) {
        case STATE_INIT:
        {
            //init shared data
            call SharedDataCInit.init();
            //crypto init = auto init
            
            //init privacy level
            call PrivacyLevelCInit.init();
            
            //privacy init
            call PrivacyCInit.init();  //mem init
            //Forwarder init = auto init
            
            //IDS init
            call IntrusionDetectCInit.init();
            //PrivacyLevel init = auto init
            
            // Signalize to the ProtectLayer that initialization is
            // completed. PL will pass this information to the application.
            // 
            // In basestation mode, further initialization is responsibility of the app.
            // 
            call Privacy.startApp(SUCCESS);
            
            m_state = STATE_READY_TO_DEPLOY;
            signal Dispatcher.stateChanged(m_state);
            
            break;
        }
        case STATE_READY_TO_DEPLOY:
        case STATE_MAGIC_RECEIVED:
        {
        	// Init Routing component
        	call RouteCInit.init();
        	
            // init key distribution component
            call KeyDistribCInit.init();
            
            m_state = STATE_READY_FOR_APP;
            signal Dispatcher.stateChanged(m_state);
            
            break;
        }
        case STATE_READY_FOR_APP:
        case STATE_WORKING:
        {
            m_state = STATE_WORKING;    
            signal Dispatcher.stateChanged(m_state);        
            
            break;
        }		
        }

        pl_log_i(TAG, "</serveState(%x)>\n", m_state); 
        pl_printfflush();
    }
    
    event void MagicPacket.magicPacketReceived(error_t status, PRIVACY_LEVEL newPrivacyLevel){
    	// Magic packet not relevant if BS, we are producing magic packet!
    }
#endif
}
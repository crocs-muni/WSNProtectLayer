package Telos;

import net.tinyos.message.*;

/**
 * AM_CON_GET_MSG message type sender
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class ConfGetSender extends BaseSenderReceiver {
    public ConfGetSender(NodeDriver parent, final String node){
        super(parent, node);
    }
    
    public void messageReceived(int to, Message m){}
    
    public void sendMessage() throws Exception {
        ConfGetMsg m = new ConfGetMsg();
        
        m.set_counter(this.parent.getMessageCounter());
        
        this.sendMessage(m);
    }
}

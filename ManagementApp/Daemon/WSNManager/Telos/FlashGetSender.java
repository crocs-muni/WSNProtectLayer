package Telos;

import net.tinyos.message.*;

/**
 * Write a description of class FlashSetSender here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class FlashGetSender extends BaseSenderReceiver {
    public FlashGetSender(NodeDriver parent, final String node){
        super(parent, node);
    }
    
    public void messageReceived(int to, Message m){}
    
    public void sendMessage() throws Exception {
        FlashGetMsg m = new FlashGetMsg();
        
        m.set_counter(this.parent.getMessageCounter());
        
        this.sendMessage(m);
    }
}

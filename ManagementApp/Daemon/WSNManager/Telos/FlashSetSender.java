package Telos;

import net.tinyos.message.*;

/**
 * Write a description of class FlashSetSender here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class FlashSetSender extends BaseSenderReceiver {
    public FlashSetSender(NodeDriver parent, final String node){
        super(parent, node);
    }
    
    public void messageReceived(int to, Message m){}
    
    public void sendMessage() throws Exception {
        FlashSetMsg m = new FlashSetMsg();
        
        m.set_counter(this.parent.getMessageCounter());
        
        this.sendMessage(m);
    }
}

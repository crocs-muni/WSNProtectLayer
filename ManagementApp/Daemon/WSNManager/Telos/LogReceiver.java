package Telos;

import App.*;
import DbDriver.RowHash;

import net.tinyos.message.*;

/**
 * Log receiver implementation. Logs cannot be send to device, therefore sender is not 
 * implemented (RuntimeException will be thrown)
 * 
 * @author Bc. Marcel Gazdik 
 * @version 2013-10-28
 */
public class LogReceiver extends BaseSenderReceiver {
    public LogReceiver(NodeDriver parent, final String node){
        super(parent, node);
    }
    
    public void messageReceived(int to, Message m){
        if(m instanceof LogMsg){
            LogMsg lm = (LogMsg)m;
            
            RowHash row = new RowHash();
            
            row.set("application_id", this.parent.getNodeApplication(this.node));
            row.set("msg", lm.getString_data());
            
            try {
                this.models.logs.save(row);
            }
            catch (Exception e){
                System.err.println(e.getMessage());
            }
        }
    }
    
    public void sendMessage() throws java.io.IOException {
        throw new RuntimeException("Log message sending is not allowed");
        //device.send(MoteIF.TOS_BCAST_ADDR, m);
    }
}

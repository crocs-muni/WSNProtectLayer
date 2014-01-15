package Telos;

import net.tinyos.message.*;


/**
 * Abstract Sender and Reveiver class definition
 * 
 * @author Bc. Marcel Gazdik    
 * @version 2013-10-28
 */
//public abstract class BaseSenderReceiver extends App.Service implements MessageListener {
public abstract class BaseSenderReceiver implements MessageListener {
    protected NodeDriver parent;
    protected Model.ModelsLoader models;
    protected App.Context context;
    protected String node;
    
    public BaseSenderReceiver(NodeDriver parent, final String node){
        //super(c);
        this.parent = parent;
        this.models = parent.getModels();
        this.context = parent.getContext();
        this.node = node;
    }
    
    //public abstract void sendMessage(MoteIF device) throws Exception;
    public abstract void sendMessage() throws Exception;
    
    //public abstract void sendMessage(MoteIF device, Message m) throws Exception;
    //public void sendMessage(MoteIF device, Message m) throws Exception {
    public void sendMessage(Message m) throws Exception {
        this.parent.getNodeInterface(this.node).send(MoteIF.TOS_BCAST_ADDR, m);
    }

}

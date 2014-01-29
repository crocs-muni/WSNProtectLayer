package Telos;
import DbDriver.*;
import App.*;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

import java.util.*;

/**
 * TelosB driver
 * 
 * @author Bc. Marcel Gazdik
 * @version (a version number or a date)
 */
public class NodeDriver extends BaseController {
    public static final String SOURCE_FORMAT = "serial@%s:telosb";
    
    private Map<String, MoteIF> nodes = new HashMap<String, MoteIF>();
    private Map<String, String> nodesToApp = new HashMap<String, String>();
    
    private static int globalMessageCounter = 0;
    
    public NodeDriver(Context c){
        super(c);
    }
    
    public void run(){
        System.out.println("Loading applications");
        try {
            for(RowStatementInterface r: this.models.applications.getEnabledApplicationsNodes()){
                if(Integer.parseInt(r.get("id")) < 0){
                    //ids bellow zero are for testing purposes (ie. temporary storage)
                    continue;
                }
                System.out.println(r);
                
                // INIT ///////////////////////////////////////////////////////////
                
                //1) register translators
                this.nodesToApp.put(r.get("id"), r.get("application_id"));
                
                //0) connect device
                this.connect(r.get("id"), r.get("device"));
                
                // USER MESSAGES //////////////////////////////////////////////////
                
                //3) register sender/receivers
                this.registerMessage(r.get("id"), new LogReceiver(this, r.get("id")), new LogMsg());
                //this.registerMessage(r.get("id"), new SavedDataSenderReceiver(this, r.get("id")), new SavedDataMsg());
                this.registerMessage(r.get("id"), new SavedDataPartSenderReceiver(this, r.get("id")), new SavedDataPartMsg());
                
                //4) upload configuration to node
                //(new SavedDataSenderReceiver(this, r.get("id"))).sendMessage();
                (new SavedDataPartSenderReceiver(this, r.get("id"))).sendMessage();
                //this message type seems to be unused...
                (new FlashSetSender(this, r.get("id"))).sendMessage();
                
                //4) download config for test
                (new ConfGetSender(this, r.get("id"))).sendMessage();
                
            }
        }
        catch (Exception e){
            throw new RuntimeException(e);
        }
    }
    
    /**
     * Create device connector
     * 
     * @param String nodeId     node id (same id as id on the battery holder)
     * @param String device     unix device (io file)
     */
    protected void connect(String nodeId, String device){
        try {
            this.nodes.put(nodeId, new MoteIF(BuildSource.makePhoenix(String.format(SOURCE_FORMAT, device), null)));
        }
        catch (Exception e){
            //log this...
        }
        //this.nodes.put(nodeId, new MoteIF());
    }
    
    /**
     * Disconnect device (destroy device connector)
     * 
     * @param String nodeId     node id ...
     */
    protected void disconnect(String nodeId){
        if(this.nodes.containsKey(nodeId)){
            this.nodes.get(nodeId).getSource().shutdown();
            this.nodes.remove(nodeId);
        }
        //else throw runtime error??
    }
    
    /**
     * returns nodes interface (MoteIF device)
     * 
     * @param final String nodeId       node id
     */
    public MoteIF getNodeInterface(final String nodeId){
        if(this.nodes.containsKey(nodeId)){
            return this.nodes.get(nodeId);
        }
        else {
            //throw something? ??
            return null;
        }
    }
    
    /**
     * register message listener
     * 
     * @param String nodeId         node id
     * @param BaseSenderReceiver    message listener (and receiver)
     */
    protected void registerMessage(String nodeId, BaseSenderReceiver r, Message m){
        if(this.nodes.containsKey(nodeId))
            this.nodes.get(nodeId).registerListener(m, r);
        //else throw runtime error??
    }
    
    /**
     * tells to shat application is nodewith given id assigned
     * 
     * @param String nodeId     node id
     * @return String
     * 
     * @throws Exception
     */
    public String getNodeApplication(final String nodeId){
        return this.nodesToApp.get(nodeId);
    }
    
    protected void finalize(){
        this.close();
    }
    
    /**
     * Destroy all conectors
     */
    public void close(){
        for(String key: this.nodes.keySet()){
            this.disconnect(key);
        }
    }
    
    /**
     * returns current counter value and automatically increase 
     */
    public int getMessageCounter(){
        return this.globalMessageCounter++;
    }
    
    /**
     * increase message counter
     */
    public void updateMessageCounter(){
        this.globalMessageCounter++;
    }
}

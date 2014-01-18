package Telos;

import App.*;
import DbDriver.*;
import java.lang.reflect.*;

import net.tinyos.message.*;

/**
 * @OBSOLETE
 * Setup message sender and reveiver implementation
 * //MUST BE REPLACED BY SavedDataPartMsg
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-28
 */
public class SavedDataSenderReceiver extends BaseSenderReceiver {
    private String application;
    
    /**
     * convert short array to string
     * 
     * @param short[] array input aray
     */
    public static String shortArrayToString(short[] array){
        StringBuilder sb = new StringBuilder();
        
        for(short tmp: array){
            if(sb.length() != 0){
                sb.append(";");
            }
            sb.append(tmp);
        }
        
        return sb.toString();
    }
    
    /**
     * convert string back to short array
     * 
     * @param String    array in formated string (<num>;<num>...)
     */
    public static short[] stringToShortArray(final String s){
        String[] splitted = s.split(";");
        short[] ret = new short[splitted.length];
        int i = 0;
        
        for(String tmp: splitted){
            ret[i] = Short.parseShort(splitted[i++]);
        } 
        
        return ret;
    }
    
    
    public SavedDataSenderReceiver(NodeDriver parent, final String node){
        super(parent, node);
        
        this.application = this.parent.getNodeApplication(this.node);
    }
    
    
    
    public void messageReceived(int to, Message m){
        if(m instanceof SavedDataMsg){
            SavedDataMsg sdm = (SavedDataMsg) m;
            
            System.out.println(sdm.get_savedDataIdx());

            
            //for each possible configuration item do:
            //row.set("item_name", ...)
            //row.set("value", ...)
            //this.models.config.save(row);
            //done;
            
            RowHash row = new RowHash();
            row.set("application_id", this.application);
            
            //row.set("node_id", this.node);
            row.set("node_id", "-1");
            
            try {       
                /*row.set("item_name","savedDataIdx");
                row.set("value", sdm.get_savedDataIdx());
                this.models.config.saveOrUpdate(row);*/
                
                /*row.set("item_name","savedData_nodeId");
                row.set("value", sdm.get_savedData_nodeId());
                this.models.config.saveOrUpdate(row);*/
                
                /*row.set("item_name","savedData_kdcData_shared_key_keyType");
                row.set("value", sdm.get_savedData_kdcData_shared_key_keyType());
                this.models.config.saveOrUpdate(row);*/
                
                row.set("item_name","savedData_kdcData_shared_key_keyValue");
                row.set("value", shortArrayToString(sdm.get_savedData_kdcData_shared_key_keyValue()));
                this.models.config.saveOrUpdate(row);
                
                /*row.set("item_name","savedData_kdcData_shared_key_dbgKeyID");
                row.set("value", sdm.get_savedData_kdcData_shared_key_dbgKeyID());
                this.models.config.saveOrUpdate(row);
                
                row.set("item_name","savedData_idsData_neighbor_reputation");
                row.set("value", sdm.get_savedData_idsData_neighbor_reputation());
                this.models.config.saveOrUpdate(row);
                
                row.set("item_name","savedData_idsData_nb_messages");
                row.set("value", sdm.get_savedData_idsData_nb_messages());
                this.models.config.saveOrUpdate(row);*/
            }
            catch (Exception e){
                System.err.println(e.getMessage());
            }
        }
    }
    
    public void sendMessage() throws java.io.IOException {
        try {
            int counterSD = 0;
            
            TableStatementInterface configs = this.models.config.getApplicationRelatedNodeConfiguration(
                this.node, 
                this.application
            );
                    
            //send message for each config_item in database
            for(RowStatementInterface row: configs){
                SavedDataMsg m = new SavedDataMsg();
                
                //System.in.read();
                
                //fill data
                /*if(row.get("item_name").equals("savedData_kdcData_shared_key_keyType")){
                    m.set_savedData_kdcData_shared_key_keyType(Short.parseShort(row.get("value")));
                }
                else if(row.get("item_name").equals("savedData_kdcData_shared_key_keyValue")){
                    m.set_savedData_kdcData_shared_key_keyValue(stringToShortArray(row.get("value")));
                }
                else if(row.get("item_name").equals("savedData_kdcData_shared_key_dbgKeyID")){
                    m.set_savedData_kdcData_shared_key_dbgKeyID(Integer.parseInt(row.get("value")));
                }
                else if(row.get("item_name").equals("savedData_idsData_neighbor_reputation")){
                    m.set_savedData_idsData_neighbor_reputation(Short.parseShort(row.get("value")));
                }
                else if(row.get("item_name").equals("savedData_idsData_nb_messages")){
                    m.set_savedData_idsData_nb_messages(Short.parseShort(row.get("value")));
                }*/
                
                
                
            }
        }
        catch (Exception e){
            System.err.println(e.getMessage());
        }
    }
}

package Telos;

import App.*;
import DbDriver.*;
import java.lang.reflect.*;

import net.tinyos.message.*;

/**
 * Setup message sender and reveiver implementation
 * //MUST BE REPLACED BY SavedDataPartMsg
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-28
 */
public class SavedDataPartSenderReceiver extends BaseSenderReceiver {
    private String application;
    
    /**
     * convert short array to string
     * 
     * @param short[] array input aray
     * @param len usable array length
     */
    public static String shortArrayToString(short[] array, short len){
        StringBuilder sb = new StringBuilder();
        
        for(int i = 0; i < len; i++){
            if(sb.length() != 0){
                sb.append(";");
            }
            sb.append(array[i]);
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
    
    
    public SavedDataPartSenderReceiver(NodeDriver parent, final String node){
        super(parent, node);
        
        this.application = this.parent.getNodeApplication(this.node);
    }
    
    
    
    public void messageReceived(int to, Message m){
        if(m instanceof SavedDataPartMsg){
            SavedDataPartMsg sdm = (SavedDataPartMsg) m;
            
            //System.out.println(sdm.get_savedDataIdx());

            
            //for each possible configuration item do:
            //row.set("item_name", ...)
            //row.set("value", ...)
            //this.models.config.save(row);
            //done;
            
            RowHash row = new RowHash();
            row.set("application_id", this.application);
            
            row.set("node_id", this.node);
            //row.set("node_id", "-1");
            
            //TODO: Export constants from Globals..
            
            try {       
                switch(sdm.get_key()){
                    case 200: //nx_uint8_t
                        row.set("item_name","savedData_kdcData_shared_key_keyType");
                        row.set("value", sdm.get_data()[0]);
                        break;
                    case 201: //nx_uint8_t * KEY_LENGTH
                        row.set("item_name","savedData_kdcData_shared_key_keyValue");
                        row.set("value", shortArrayToString(sdm.get_data(), sdm.get_len()));
                        break;
                    case 202: //nx_uint16_t
                        short[] tmpValue = new short[2];
                        row.set("item_name","savedData_kdcData_shared_key_dbgKeyID");
                        tmpValue[0] = sdm.get_data()[0];
                        tmpValue[1] = sdm.get_data()[1];
                        row.set("value", shortArrayToString(tmpValue, (short)2));
                        break;
                    case 203: //nx_uint8_t
                        row.set("item_name","savedData_kdcData_counter");
                        row.set("value", sdm.get_data()[0]);
                        break;
                    case 204: //nx_uint8_t
                        row.set("item_name","savedData_idsData_neighbor_reputation");
                        row.set("value", sdm.get_data()[0]);
                        break;
                    case 205: //nx_uint8_t
                        row.set("item_name","savedData_idsData_nb_messages");
                        row.set("value", sdm.get_data()[0]);
                        break;
                    default:
                        throw new Exception("Ivalid key value: " + sdm.get_key());
                }
                
                this.models.config.saveOrUpdate(row);
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
                SavedDataPartMsg m = new SavedDataPartMsg();
                
                //m.set_counter(this.parent.getMessageCounter());
                
                //fill data
                if(row.get("item_name").equals("savedData_kdcData_shared_key_keyType")){
                    m.set_key((short)200);
                    m.set_len((short)1);
                    m.set_data(new short[]{Short.parseShort(row.get("value"))});
                }
                else if(row.get("item_name").equals("savedData_kdcData_shared_key_keyValue")){
                    short[] key = stringToShortArray(row.get("value"));

                    m.set_key((short)201);
                    m.set_len((short)key.length);
                    m.set_data(key);
                }
                else if(row.get("item_name").equals("savedData_kdcData_shared_key_dbgKeyID")){
                    short[] key = stringToShortArray(row.get("value"));
                    
                    m.set_key((short)202);
                    m.set_len((short)2);
                    m.set_data(key);
                }
                else if(row.get("item_name").equals("savedData_kdcData_counter")){
                    m.set_key((short)203);
                    m.set_len((short)1);
                    m.set_data(new short[]{Short.parseShort(row.get("value"))});
                }
                else if(row.get("item_name").equals("savedData_idsData_neighbor_reputation")){
                    m.set_key((short)204);
                    m.set_len((short)1);
                    m.set_data(new short[]{Short.parseShort(row.get("value"))});
                }
                else if(row.get("item_name").equals("savedData_idsData_nb_messages")){
                    m.set_key((short)205);
                    m.set_len((short)1);
                    m.set_data(new short[]{Short.parseShort(row.get("value"))});
                }
                else {
                    throw new Exception("Invalid item name: " + row.get("item_name"));
                }
                     
                this.sendMessage(m);
            }
        }
        catch (Exception e){
            System.err.println(e.getMessage());
        }
    }
}

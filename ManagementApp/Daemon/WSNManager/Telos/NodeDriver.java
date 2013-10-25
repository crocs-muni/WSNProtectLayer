package Telos;
import DbDriver.*;
import App.*;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

/**
 * Write a description of class NodeDriver here.
 * 
 * @author Bc. Marcel Gazdik
 * @version (a version number or a date)
 */
public class NodeDriver extends BaseController implements MessageListener {
    public NodeDriver(Context c){
        super(c);
    }
    
    public void run(){
        System.out.println("Loading applications");
        try {
            for(RowStatementInterface r: this.models.applications.getEnabledApplicationsNodes()){
                System.out.println(r);
            }
        }
        catch (Exception e){
            throw new RuntimeException(e);
        }
    }
    
     public void messageReceived(int to, Message m){
         //save logs
         if(m.amType() == 11){ //dummy....
             
         }     
     }
}

package Telos;
import DbDriver.*;
import App.*;

/**
 * Write a description of class NodeDriver here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class NodeDriver extends BaseController {
    public NodeDriver(Context c){
        super(c);
    }
    
    public void run(){
        try {
            for(RowStatementInterface r: this.models.nodes.get()){
                //new ListeningNode();
            }
        }
        catch (Exception e){
            throw new RuntimeException(e);
        }
    }
}

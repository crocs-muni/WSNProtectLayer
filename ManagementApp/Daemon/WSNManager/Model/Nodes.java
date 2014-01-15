package Model;
import DbDriver.*;

/**
 * Node table model
 * 
 * @author Bc. Marcel Gazdik 
 * @version 2013-10-26
 */
public class Nodes extends BaseModel {
    public Nodes(App.Context c){
        super(c);
    }
    
    public String getTableName(){
        return "node";
    }
}

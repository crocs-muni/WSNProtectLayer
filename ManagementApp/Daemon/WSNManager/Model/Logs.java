package Model;
import DbDriver.*;

/**
 * Log table model
 * 
 * @author Bc.Marcel Gazdik
 * @version 2013-10-26
 */
public class Logs extends BaseModel {
    public Logs(App.Context c){
        super(c);
    }
    
    public String getTableName(){
        return "logs";
    }
}

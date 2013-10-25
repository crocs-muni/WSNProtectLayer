package Model;
import DbDriver.*;

/**
 * Write a description of class Logs here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class Logs extends BaseModel {
    public Logs(App.Context c){
        super(c);
    }
    
    public String getTableName(){
        return "logs";
    }
}

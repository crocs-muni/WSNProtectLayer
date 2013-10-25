package Model;
import DbDriver.*;


/**
 * Write a description of class Applications here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class Applications extends BaseModel {
    public Applications(App.Context c){
        super(c);
    }
    
    public String getTableName(){
        return "application";
    }
    
    public final TableStatementInterface getEnabledApplications() throws DbReadException {
        return this.database.query("SELECT * FROM " + this.getTableName() + " WHERE `enabled` = TRUE");
    }
    
    public final TableStatementInterface getEnabledApplicationsNodes() throws DbReadException {
        String node = ((BaseModel)this.getContext().get("model.nodes")).getTableName();
        String application = ((BaseModel)this.getContext().get("model.applications")).getTableName();
        
        return this.database.query(
            "SELECT " + 
                "`" + node + "`.* " +
            "FROM `" + node + "_to_" + application + "`" +
            "LEFT JOIN `" + application + "` ON(" +
                "`" + application + "`.`id` = `" + node + "_to_" + application + "`.`" + application + "_id`" +
            ") " +
            "LEFT JOIN `" + node + "` ON (" +
                "`" + node + "`.`id` = `" + node + "_to_" + application + "`.`" + node + "_id`" +
            ") " +
            "WHERE `" + application + "`.`enabled` = TRUE"
        );
    }
}

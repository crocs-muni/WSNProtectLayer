package Model;
import DbDriver.*;


/**
 * Application table model
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-26
 */
public class Applications extends BaseModel {
    public Applications(App.Context c){
        super(c);
    }
    
    public String getTableName(){
        return "application";
    }
    
    /**
     * return all enabled applications
     * 
     * @return TableStatementInterface
     * 
     * @throws DbReadException
     */
    public final TableStatementInterface getEnabledApplications() throws DbReadException {
        return this.database.query("SELECT * FROM " + this.getTableName() + " WHERE `enabled` = TRUE");
    }
    
    /**
     * load all nodes from database, which are connected with specified application
     * 
     * @return TableStatementInterface
     * 
     * @throws DbReadException
     */
    public final TableStatementInterface getEnabledApplicationsNodes() throws DbReadException {
        String node = ((BaseModel)this.getContext().get("model.nodes")).getTableName();
        String application = ((BaseModel)this.getContext().get("model.applications")).getTableName();
        
        return this.database.query(
            "SELECT " + 
                "`" + node + "`.*, " +
                "`application`.`id` AS `application_id` " +
            "FROM `" + node + "_to_" + application + "` " +
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

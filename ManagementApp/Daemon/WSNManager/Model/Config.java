package Model;
import DbDriver.*;
import App.*;

/**
 * Write a description of class Config here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class Config extends BaseModel {
    public Config(App.Context c){
        super(c);
    }
    
    public String getTableName(){
        return "config";
    }
    
    /**
     * returns node configuration directvices specific for given application
     * 
     * @param final String nodeId           node id
     * @param final String applicationId    application id
     */
    public TableStatementInterface getApplicationRelatedNodeConfiguration(final String nodeId, final String applicationId) throws Exception {
        return this.database.query("SELECT * FROM `" + this.getTableName() + "` WHERE `application_id` = '" + applicationId + "' AND `node_id` = '" + nodeId + "'");
    }
}

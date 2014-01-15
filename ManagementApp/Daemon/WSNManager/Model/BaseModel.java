package Model;
import DbDriver.*;
import App.*;

/**
 * Abstract class BaseModel - write a description of the class here
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-26
 */
public abstract class BaseModel extends App.Service {
    protected DatabaseInterface database;
    
    //public BaseModel(DatabaseInterface db){
    public BaseModel(Context context){
        super(context);
        this.database = (DatabaseInterface)context.get("database");
    }
    
    //add clone or something...
    public final DatabaseInterface getDatabase(){
        return this.database;
    }
    
    /**
     * get models table name
     * 
     * @return String
     */
    public abstract String getTableName();
    
    /**
     * save data into database
     * 
     * @param Object data   Array of objects containing data itself or
     *                      ArraHash with data and column names
     *                      
     * @throws DbWriteException
     */
    public void save(final Object data) throws DbWriteException {
        if(data instanceof App.ArrayHash || data instanceof RowHash){
            this.database.exec("INSERT INTO `" + this.getTableName() + "` ?", data);
        }
        else {
            this.database.exec("INSERT INTO `" + this.getTableName() + "` VALUES(?)", data);
        }
    }
    
    /**
     * save data into database, or update row with same key
     * 
     * @param Object data   ArraHash/RowHash with data and column names
     *                      
     * @throws DbWriteException
     */
    public void saveOrUpdate(final Object data) throws DbWriteException {
        if(data instanceof ArrayHash || data instanceof RowHash){  
            StringBuilder newValues = new StringBuilder();
            
            for(String key: (ArrayHash) data){
                if(newValues.length() != 0)
                    newValues.append(", ");
                    
                newValues.append("`" + key + "` = '" + ((ArrayHash)data).get(key) + "'");
            }
            
            this.database.exec("INSERT INTO `" + this.getTableName() + "` ? ON DUPLICATE KEY UPDATE " + newValues.toString(), data);
        }
    }
    
    /**
     * update data in database
     * 
     * @param Object id         unique row identificator (could be only one, or array)
     * @param ArrayHash data    new data with column names
     */
    public void update(final Object id, final App.ArrayHash data) throws DbWriteException {
        this.update(id, data, "id");
    }
    
    /**
     * update data in database
     * 
     * @param Object id         unique row identificator (could be only one, or array)
     * @param ArrayHash data    new data with column names
     * @param String column     column with unique identifiers
     */
    public void update(final Object id, final App.ArrayHash data, final String column) throws DbWriteException {
        this.database.exec("UPDATE `" + this.getTableName() + "` ? WHERE `" + column + "` IN(?)", data, id);
    }
    
    /**
     * delete row specifed by id/id's from database
     * 
     * @param Object id     unique row identificator (could be only one, or array)
     */
    public void delete(final Object id) throws DbWriteException {
        this.delete(id, "id");
    }
    
    /**
     * delete row specifed by id/id's from database
     * 
     * @param Object id     unique row identificator (could be only one, or array)
     * @param String column column name with unique identificatos
     */
    public void delete(final Object id, final String column) throws DbWriteException {
        this.database.exec("DELETE FROM `" + this.getTableName() + "` WHERE `" + column + "` IN (?)", id);
    }
    
    /**
     * return all rows from table
     */
    public TableStatementInterface get() throws Exception {
        return this.database.query("SELECT * FROM `" + this.getTableName() + "`");
    }
    
    /**
     * return all rows with specified value in id columnt
     * 
     * @param Object id unique row identificator
     */
    public TableStatementInterface get(final Object id) throws Exception { 
        return this.get(id, "id");
    }
    
    /**
     * return all rows with specified value in id columnt
     * 
     * @param Object id         unique row identificator
     * @param String column     column with unique identificators
     */
    public TableStatementInterface get(final Object id, final String column) throws Exception {
        return this.database.query("SELECT * FROM `" + this.getTableName() + "` WHERE `" + column + "` IN (?)", id);
    }
}

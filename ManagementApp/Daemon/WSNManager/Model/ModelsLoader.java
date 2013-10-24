package Model;
import DbDriver.*;


/**
 * Write a description of class ModelLoader here.
 * 
 * @author Bc. Marcel Gazdik 
 * @version 2013-10-21
 */
public class ModelsLoader {
    private Database database;
    
    //list of all existing models (do not forget initialize each one)
    public Nodes nodes;
    
    
    public ModelsLoader(final String database, final String user, final String password){
        this.database = new Database(database, user, password);
        
        nodes = new Nodes(this.database);
    }
    
    public Database getDatabase(){
        return this.database;
    }
    
    //shortcut
    public Database db(){
        return this.getDatabase();
    }
}

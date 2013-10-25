package Model;
import DbDriver.*;
import App.*;


/**
 * Write a description of class ModelLoader here.
 * 
 * @author Bc. Marcel Gazdik 
 * @version 2013-10-21
 */
public class ModelsLoader extends App.Service {
    private DatabaseInterface database;
    
    //list of all existing models (do not forget initialize each one)
    public Nodes nodes;
    public Logs logs;
    public Applications applications;
    
    
    //public ModelsLoader(final String database, final String user, final String password){
    public ModelsLoader(Context c){
        super(c);
        
        this.database = (DatabaseInterface)c.get("database");
        
        this.nodes = new Nodes(c);
        this.logs = new Logs(c);
        this.applications = new Applications(c);
    }
    
    public DatabaseInterface getDatabase(){
        return this.database;
    }
    
    //shortcut
    public DatabaseInterface db(){
        return this.getDatabase();
    }
    
    /*@Override
    protected String getServiceName(){
        return "models";
    }*/
}

package DbDriver; 

import java.sql.*;
import java.util.Map;
import java.util.TreeMap;

/**
 * SQL database driver
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-21
 */
public class Database extends App.Service implements DatabaseInterface {
    private Connection          connection;

    private DatabaseMetaData    dbMetadata;
   
    //database information
    private String dbName = null;
    private String user = null;
    private String password = null;
       
    
    //public Database(final String dbName, final String user, final String password){
    public Database(App.Context c){
        super(c);
        try{
            App.ArrayHash config = (App.ArrayHash)c.get("configuration");
            this.dbName = config.get("database").toString();
            this.user = config.get("user").toString();
            this.password = config.get("password").toString();
            
            this.connect();
        }
        catch (DbException e){
            System.err.println(e.getMessage());
            System.err.println();
        }
    }
    
    protected String getServiceName(){
        return "database";
    }
    
    
    public void connect() throws DbException {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            
            this.connection = DriverManager.getConnection("jdbc:mysql://localhost/" + dbName + "?user=" + user + "&password=" + password);
            
            this.dbMetadata = this.connection.getMetaData();
        }
        catch (Exception e){
            throw new DbException(e);
        }
    }
    
    
    public TableStatement query(final String query, Object ... args) throws DbReadException {
        //return new TableStatement(query, this.connection);
        try {            
            SqlBuilder sb = new SqlBuilder(this.connection, query, args);
            return new TableStatement(sb.getStatement());
        }
        catch (Exception e){
            throw new DbReadException(e);
        }
    }
    
    
    public void exec(final String execQuery, Object ... args) throws DbWriteException {
        try {            
            SqlBuilder sb = new SqlBuilder(this.connection, execQuery, args);
            sb.getStatement().executeUpdate();
        }
        catch (Exception e){
            throw new DbWriteException(e);
        }
    }
    
    public void beginTransaction() throws DbException {
        try {
            this.connection.setAutoCommit(false);
        }
        catch (Exception e){
            throw new DbException(e);
        }
    }
    
    public void commit() throws DbException{
        try {
            this.connection.commit();
        }
        catch (Exception e){
            
        }
    }
    
    public void rollback() throws DbException{
        try {
            this.connection.rollback();
        }
        catch (Exception e){
            throw new DbException(e);
        }
    }
    
    public boolean inTransaction(){
        try {
            return !this.connection.getAutoCommit();
        }
        catch (Exception e){
            return false;
        }
    }
}

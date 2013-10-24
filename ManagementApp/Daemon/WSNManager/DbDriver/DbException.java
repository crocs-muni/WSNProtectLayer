package DbDriver; 


/**
 * Database Exception
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-3-11
 */
public class DbException extends Exception {
    public DbException(){
        super();
    }
    
    public DbException(String message){
        super(message);
    }
    
    public DbException(String message, Throwable cause){
        super(message, cause);
    }
    
    public DbException(Throwable cause){
        super(cause);
    }
}

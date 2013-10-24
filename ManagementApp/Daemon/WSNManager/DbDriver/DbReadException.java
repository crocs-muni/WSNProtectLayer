package DbDriver; 


/**
 * Database Exception
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-3-11
 */
public class DbReadException extends DbException {
    public DbReadException(){
        super();
    }
    
    public DbReadException(String message){
        super(message);
    }
    
    public DbReadException(String message, Throwable cause){
        super(message, cause);
    }
    
    public DbReadException(Throwable cause){
        super(cause);
    }
}

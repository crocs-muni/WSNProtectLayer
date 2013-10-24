package DbDriver; 


/**
 * Database Exception
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-3-11
 */
public class DbWriteException extends DbException {
    public DbWriteException(){
        super();
    }
    
    public DbWriteException(String message){
        super(message);
    }
    
    public DbWriteException(String message, Throwable cause){
        super(message, cause);
    }
    
    public DbWriteException(Throwable cause){
        super(cause);
    }
}

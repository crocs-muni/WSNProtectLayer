package App;


/**
 * Abstract class Service is basic implementation of service.
 * This implementation automatically register all descendant 
 * implementation as services and provides protected context
 * class parameter for all their descendant.
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-25
 */
public abstract class Service implements ServiceInterface {
    protected Context context;
    
    public Service(Context c){
        this.context = c;
        
        this.context.set(this.getServiceName(), this);
    }
    
    /**
     * return current context
     * 
     * @return App.Context
     */
    public final Context getContext(){
        return context;
    }
    
    /**
     * returns service name, default name is complete path to class with it's name
     * but it could be changed by implementing this method for any reason
     * 
     * @return String
     */
    public String getServiceName(){
        return this.getClass().getName().toLowerCase();
    }
    
    /**
     * Clearly close service
     */
    public void close(){
    }
}

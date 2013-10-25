package App;


/**
 * Abstract class Service Objects implementing this class
 * will be automatically registered as a service and they
 * 
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-25
 */
public abstract class Service {
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
    protected String getServiceName(){
        return this.getClass().getName().toLowerCase();
    }
}

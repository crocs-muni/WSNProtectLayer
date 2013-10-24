package App;
import Model.ModelsLoader;

/**
 * Write a description of class BaseController here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
abstract public class BaseController {
    protected Context context;
    protected ModelsLoader models;
    
    public BaseController(Context c){
        this.context = c;
        this.models = ((ModelsLoader)c.get("models"));
    }
    
    public Context getContext(){
        return context;
    }
}

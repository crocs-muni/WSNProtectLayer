package App;
import Model.ModelsLoader;

/**
 * Extended controller service. Provides automatically loaded
 * context and modules for further operations.
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-25
 */
abstract public class BaseController extends Service {
    protected ModelsLoader models;
    
    public BaseController(Context c){
        super(c);

        this.models = ((ModelsLoader)c.get("model.modelsloader"));
    }
    
    /**
     * returns all loaded models in model loader
     * 
     * @return Model.ModelsLoader
     */
    public ModelsLoader getModels(){
        return this.models;
    }
}

package App;

/**
 * Write a description of class Context here.
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-25
 */
public class Context extends ArrayHash {
    @Override
    public Object get(final String key){
        if(!this.hasItem(key))
            throw new RuntimeException("Service " + key + " not loaded");
        else
            return super.get(key);
    }
}

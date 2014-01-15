package App;


/**
 * Freezable class interface
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-26
 */
public interface Freezable {
    /**
     * Freez object, allow only read operations
     */
    public void freeze();
    
    /**
     * check if object is frozen
     * 
     * @return boolean
     */
    public boolean isFrozen();
}

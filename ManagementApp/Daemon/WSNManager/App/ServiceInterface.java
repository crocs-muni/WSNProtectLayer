package App;


/**
 * Service interface
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-26
 */
public interface ServiceInterface
{
    /**
     * returns service name, default name is complete path to class with it's name
     * but it could be changed by implementing this method for any reason
     * 
     * @return String
     */
    public String getServiceName();
    
    /**
     * Clearly close service
     */
    public void close();
}

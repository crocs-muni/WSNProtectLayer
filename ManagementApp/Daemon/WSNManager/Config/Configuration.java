package Config;


/**
 * Configuration storage service
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-28
 */
public class Configuration extends App.ArrayHash implements App.ServiceInterface {
    public String getServiceName(){
        return "configuration";
    }
    
    public void close(){}
}

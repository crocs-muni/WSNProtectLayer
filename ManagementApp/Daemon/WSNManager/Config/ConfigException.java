package Config;

/**
 * Write a description of class ConfigException here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class ConfigException extends Exception {
    public ConfigException(){
        super();
    }
    
    public ConfigException(String message){
        super(message);
    }
    
    public ConfigException(String message, Throwable cause){
        super(message, cause);
    }
    
    public ConfigException(Throwable cause){
        super(cause);
    }
}

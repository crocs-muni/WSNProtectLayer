import DbDriver.*;
import Model.*;
import App.*;
/**
 * Write a description of class Main here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class Main
{    
    public static void main(String [] arg){
        try {
            Main m = new Main();
            m.run();
        }
        catch (Exception e){
            System.err.println(e.getMessage());
        }
    }
    
    public Main() {}
    
    public void run(){
        try {
            //read config file;
            ConfigLoader.Configuration c = new ConfigLoader("wsnmanager.conf.xml").getConfig();
            
            //initialize context with services
            Context context = new Context();

            //register current configuration as a data service
            context.set("configuration", c);
           
            //Class extending Service 
            new Database(context);
            new ModelsLoader(context);
            Telos.NodeDriver d = new Telos.NodeDriver(context);
            
            //freeze context
            context.freeze();
            
            
            //run services
            d.run();
        }
        catch (Exception e){
            throw new RuntimeException(e);
        }
    }
}

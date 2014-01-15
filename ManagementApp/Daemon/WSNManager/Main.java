import DbDriver.*;
import Model.*;
import App.*;
import Config.*;

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
            //initialize context with services
            Context context = new Context();
            
            //read config file;
            Configuration c = new ConfigLoader("wsnmanager.conf.xml").getConfig();

            //register current configuration as a data service
            context.set(c.getServiceName(), c);
           
            //Class extending Service 
            new Database(context);
            new ModelsLoader(context);
            Telos.NodeDriver d = new Telos.NodeDriver(context);
            
            //freeze context
            context.freeze();
            
            
            //run services
            d.run();
            
            
            ///// SOME TESTS... //////////////
            /*ModelsLoader m = (ModelsLoader)context.get("model.modelsloader");
            
            ArrayHash r = new ArrayHash();
            
            short[] dd = new short[]{1,2,3};
            
            
            r.set("application_id", "101");
            r.set("node_id", "21");
            r.set("item_name", "test");
            r.set("value", shortArrayToString(dd));
            
            m.config.saveOrUpdate(r);
            
            String dds = shortArrayToString(dd);
            short[] ddr = stringToShortArray(dds);
            
            for(short tmp: ddr){
                System.out.println(tmp);
            }*/
        }
        catch (Exception e){
            throw new RuntimeException(e);
        }
    }
}

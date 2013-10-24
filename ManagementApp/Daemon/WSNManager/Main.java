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
            
            //initialize context
            Context context = new Context();

            
            context.set("models", 
                new ModelsLoader(
                    c.get("database").toString(), 
                    c.get("user").toString(), 
                    c.get("password").toString()
                )
            );
            
            context.freeze();
            
            new Telos.NodeDriver(context).run();
            
            /*this.models.nodes.delete(new Object[]{100});
            
            this.models.db().beginTransaction();
            
            ArrayHash row = new ArrayHash();
            row.set("id", 100);
            row.set("device", "/dev/null");
            
            this.models.nodes.save(row);
            
            row = new ArrayHash();
            row.set("device", "/dev/null000");
            
            this.models.nodes.update(100, row);

            for(RowStatementInterface r : this.models.nodes.get()){
                System.out.println(r);
            }
            
            this.models.nodes.delete(new Object[]{1000,1001, "ff"});
            
            this.models.db().rollback();*/
        }
        catch (Exception e){
            throw new RuntimeException(e);
        }
    }
}

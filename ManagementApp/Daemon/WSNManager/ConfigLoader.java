import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import java.io.File;

/**
 * XML config loader
 * 
 * @author Bc. Marcel Gazdik 
 * @version 2013-10-21
 */
public class ConfigLoader {  
    private Configuration c;
    private String path;
    
    public ConfigLoader(final String path) throws ConfigException {
        this.path = path;
        this.read();
    }
    
    public void read() throws ConfigException {
        try {
            this.c = new Configuration();
            
            File configFile = new File(this.path);
             
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
            Document doc = dBuilder.parse(configFile);
            doc.getDocumentElement().normalize();
            
            //get config groups
            NodeList list = doc.getElementsByTagName("group");

            for(int i = 0; i < list.getLength(); i++){
                Node node = list.item(i);
                
                if(node.getNodeType() == Node.ELEMENT_NODE){
                    Element element = (Element)node;
                    
                    //parse database configuration
                    if(element.getAttribute("id").equals("database")){
                        this.c.set("database", element.getElementsByTagName("database").item(0).getTextContent());
                        this.c.set("user", element.getElementsByTagName("user").item(0).getTextContent());
                        this.c.set("password", element.getElementsByTagName("password").item(0).getTextContent());
                    }
                }
            }
        }
        catch (Exception e){
            throw new ConfigException(e);
        }
    }
    
    public Configuration getConfig(){
        return this.c;
    }
    
    public class Configuration extends App.ArrayHash {}
}

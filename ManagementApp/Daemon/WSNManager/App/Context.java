package App;
import java.util.*;

/**
 * Service register. All classes implementig Service class will be automatically
 * registered as a service. Classes implementing ServiceInterface only has to be
 * registered manualy by calling method set (class.getServiceName, class).
 * 
 * On shutdown will be called ServiceInterface.close() in vice versa order.
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-25
 */
public class Context implements Countable, Iterable<String>, Freezable {
    private Map<String, ServiceInterface> services = new HashMap<String, ServiceInterface>();
    private List<String> order = new ArrayList<String>();
    private boolean freezed = false;
    
    /**
     * thread which closes all services in reverse order, than they were created
     */
    private class CloseThread extends Thread {
        private Context c;
        
        public CloseThread(Context c){
            this.c = c;
        }
        
        @Override
        public void run(){
            Iterator<String> i = c.reverseIterator();
            
            while(i.hasNext()){
                //System.out.println(i.next());
                ((ServiceInterface)c.get(i.next())).close();
            }
        }
    }
    
    public Context(){
        Runtime.getRuntime().addShutdownHook(new CloseThread(this));
    }
    
    /**
     * register service into context
     * 
     * @param String key        service name
     * @param ServiceInterface  service class
     * 
     * @throws RuntimeException this container is frozen
     */
    public void set(final String key, ServiceInterface s){
        if(this.freezed)
            throw new RuntimeException("Cannot modify freezed object");
            
        this.services.put(key, s);
        this.order.add(key);
    }
    
    /**
     * returns service object (need to be cast)
     * 
     * @param String key    service name
     * 
     * @return Object
     * 
     * @throws RuntimeException if service is not registered
     */
    public Object get(final String key){
        if(!this.services.containsKey(key))
            throw new RuntimeException("Service " + key + " not loaded");
        else
            return this.services.get(key);
    }
    
    // COUNTABLE Interface
    public int count(){
        return this.services.size();
    }
    
    // ITERABLE Interface
    public Iterator<String> iterator(){
        return new ItemIterator();
    }
    
    public Iterator<String> reverseIterator(){
        return new ReverseItemIterator();
    }
    
    private class ItemIterator implements Iterator<String> {
        private Iterator<String> i = order.iterator();
        
        public boolean hasNext(){
            return this.i.hasNext();
        }
        
        public String next(){
            return this.i.next();
        }
        
        public void remove(){
            //this.i.remove();
            throw new RuntimeException("Not implemented");
        }
    }
    
    private class ReverseItemIterator implements Iterator<String> {
        private ListIterator<String> i = order.listIterator(order.size());
        
        public boolean hasNext(){
            return this.i.hasPrevious();
        }
        
        public String next(){
            return this.i.previous();
        }
        
        public void remove(){
            throw new RuntimeException("Not implemented");
            //this.i.close();
            //this.i.remove();
        }
    }
    
    // FREEZABLE Interface
    public void freeze(){
        this.freezed = true;
    }
    
    public boolean isFrozen(){
        return this.freezed;
    }
    
    @Override
    public String toString(){
        StringBuilder sb = new StringBuilder();
        
        sb.append("{");
        sb.append(System.getProperty("line.separator"));
        for(String key: this){
            sb.append("\t");
            sb.append(key);
            sb.append(" => ");
            sb.append(this.get(key).toString());
            sb.append(System.getProperty("line.separator"));
        }
        sb.append("}");
        
        return sb.toString();
    }
}

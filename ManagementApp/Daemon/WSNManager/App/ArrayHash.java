package App;
import java.util.*;


/**
 * HashArray data container
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-21
 */
public class ArrayHash implements Iterable<String>, Countable {
    private Map<String, Object> data = new TreeMap<String, Object>();
    boolean freezed = false;
    
    /**
     * add new entry into array
     * 
     * @param String key    key entry (used as acolumn name..)
     * @param Object value  entry value, could be any data class such as Integer
     */
    public void set(final String key, final Object value){
        if(this.freezed)
            throw new RuntimeException("Cannot modify freezed object");
        
        data.put(key, value);
    }
    
    /**
     * returns object in array specified by key
     * 
     * @param String key    entry key
     * @return Object
     */
    public Object get(final String key){
        if(this.hasItem(key))
            return data.get(key);
        else
            return null;
    }
    
    /**
     * remove key->val set from array
     * 
     * @param String key    value key
     */
    public void unset(final String key){
        if(this.hasItem(key))
            this.data.remove(key);
    }
    
    public boolean hasItem(final String key){
        return this.data.containsKey(key);
    }
    
    public void freeze(){
        //this.freeze(); //causes stacowerflow error
        this.freezed = true;
    }
    
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
    
    public Iterator<String> iterator(){
        return new ItemIterator();
    }
    
    private class ItemIterator implements Iterator<String> {
        private Iterator<String> i = data.keySet().iterator();
        
        public boolean hasNext(){
            return this.i.hasNext();
        }
        
        public String next(){
            return this.i.next();
        }
        
        public void remove(){
            this.i.remove();
        }
    }
    
    public int count(){
        return this.data.size();
    }
}

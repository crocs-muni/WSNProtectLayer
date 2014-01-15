package DbDriver;
import java.sql.*;
import java.util.*;


/**
 * Build sql query statement
 * 
 * @author Bc. Marcel Gazdik 
 * @version 2013-10-21
 */
public class SqlBuilder {
    private PreparedStatement ps = null;
    private List<Object> args = new ArrayList<Object>();
    private String query;
    
    private StringBuilder sb = new StringBuilder();
    private String[] parts;
    
    /*private boolean insertWithSet = false;
    private boolean insertWithoutSet = false;
    private boolean update = false;*/
    
    public SqlBuilder(final Connection c, final String query, Object ... args) throws DbException {
        try {
            this.ps = c.prepareStatement(query);
            this.query = query;

            ParameterMetaData pd = ps.getParameterMetaData();
            
            if(pd.getParameterCount() != args.length)
                throw new DbException("Argument count doesn't match");
            

            this.parts = this.query.split("\\?");
            sb.append(parts[0]);
            
            
            this.explodeArgs(true, args);
            
            this.query = this.sb.toString();
            
            this.ps = c.prepareStatement(this.query);
            pd = ps.getParameterMetaData();
            
            for(int i = 0; i < pd.getParameterCount(); i++){
                ps.setString(i + 1, this.args.get(i).toString());  
            }
         
            //System.out.println(ps);
        }
        catch (Exception e){
            throw new DbException(e);
        }
    }
    
    public PreparedStatement getStatement(){
        return this.ps;
    }
    
    protected void explodeArgs(boolean append, Object ... args){
        int partIndex = 1;
        for(Object o: args){
            if(o instanceof App.ArrayHash){
                this.sb.append(" SET ");
                for(String i: (App.ArrayHash)o){
                    this.sb.append("`");
                    this.sb.append(i);
                    this.sb.append("`");
                    this.sb.append(" = ?,");
                    this.explodeArgs(false, ((App.ArrayHash)o).get(i));
                }
                this.sb.deleteCharAt(this.sb.length() - 1);
            }
            else if(o.getClass().isArray()){
                int l = ((Object[])o).length - 1;
                
                this.sb.append("?");
                for(int i = 0; i < l; i++){
                    this.sb.append(", ?");
                }
                
                this.explodeArgs(false, (Object[])o);
            }
            else {
                this.args.add(o);
                
                if(append)
                    this.sb.append("?");
            }
            
            if(append && partIndex < this.parts.length){
                this.sb.append(this.parts[partIndex++]);
            }
        }
    }
}

package DbDriver;
import java.sql.*;

/**
 * MySQL Row statement interface implementation 
 * 
 * @author Bc.Marcel Gazdik
 * @version 2013-10-20
 */
public class RowStatement implements RowStatementInterface {
    private ResultSet           rs;
    private ResultSetMetaData   md;
    
    public RowStatement(final ResultSet rs) throws DbReadException {
        this.rs = rs;
        
        try {
            this.md = rs.getMetaData();
        }
        catch (Exception e){
            throw new DbReadException(e);
        }
    }
    
    public String get(final String name) throws DbReadException {
        try {
            return this.rs.getString(name);
        }
        catch (Exception e){
            throw new DbReadException(e);
        }
    }

    public String get(final int index) throws DbReadException {
        try {
            return this.rs.getString(index);
        }
        catch (Exception e){
            throw new DbReadException(e);
        }
    }
    
    public RowHash toArray(){
        return null;
    }
    
    public String toString(){
        StringBuilder sb = new StringBuilder();
        
        try {
            sb.append("|");
            for(int i = 1; i <= this.md.getColumnCount(); i++){
                sb.append(" ");
                sb.append(this.get(i));
                sb.append(" |");
            }
        }
        catch (Exception e){
            sb = new StringBuilder();
            sb.append(e.getMessage());
        }
        
        return sb.toString();
    }
}

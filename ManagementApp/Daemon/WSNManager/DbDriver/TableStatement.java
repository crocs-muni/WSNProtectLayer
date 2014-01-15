package DbDriver;
import java.sql.*;
import java.util.Iterator;

/**
 * MySQL TableStatementInterface implementation
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-21
 */
public class TableStatement implements TableStatementInterface {
    private PreparedStatement   ps;
    private ResultSet           rs;
    
    private int                 count;
    //private DatabaseMetaData    dbmd;
    
    public TableStatement(PreparedStatement ps) throws DbReadException {
        try {
            this.rs = ps.executeQuery();
            this.count = -1;
        }
        catch (Exception e){
            throw new DbReadException(e);
        }
    }
    
    public RowStatement getRowAt(final int row) throws DbReadException {
        try {
            if(!this.rs.absolute(row))
                return null;
            else {
                return new RowStatement(this.rs);
            }
        }
        catch (Exception e){
            throw new DbReadException(e);
        }
    }
    
    public RowStatement getNext() throws DbReadException {
        try {
            if(!this.rs.next())
                return null;
            else {
                return new RowStatement(this.rs);
            }
        }
        catch (Exception e){
            throw new DbReadException(e);
        }
    }
    
    public RowStatement getPrevious() throws DbReadException {
        try {
            if(!this.rs.previous())
                return null;
            else {
                return new RowStatement(this.rs);
            }
        }
        catch (Exception e){
            throw new DbReadException(e);
        }
    }
    
    public int count(){
        try {
            if(this.count < 0){
                int tmp = this.rs.getRow();
                
                this.rs.last();
                this.count = this.rs.getRow();
                
                if(tmp != 0)
                    this.rs.absolute(tmp);
                else
                    this.rs.beforeFirst();
            }
            
            return this.count;
        }
        catch (Exception e){
            return 0;
        }
    }
    
    //== ITERATOR =====
    public Iterator<RowStatement> iterator(){
        return new RowIterator();
    }
    
    private class RowIterator implements Iterator<RowStatement> {
        public boolean hasNext(){
            try {
                boolean r = rs.next();
                rs.previous();
                return r;
            } 
            catch (Exception e){
                return false;
            }
        }
    
        public RowStatement next(){
            try {
                return getNext();
            } catch (Exception e){}
            return null;
        }
    
        public void remove(){
            //throw new UnsupportedOperaionException();
        };
    }
}

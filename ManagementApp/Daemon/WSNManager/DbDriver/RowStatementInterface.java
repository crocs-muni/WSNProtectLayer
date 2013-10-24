package DbDriver;
/**
 * Row statement interface
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-20
 */
public interface RowStatementInterface {
    /**
     * get column value from current row addressed by column index
     * 
     * @param final int index     column index
     * 
     * @throws DbReadException
     */
    String get(final int index) throws DbReadException;
    
    /**
     * get column value from current row addressed column name
     * 
     * @param final String     column name
     * 
     * @throws DbReadException
     */
    String get(final String column) throws DbReadException;
    
    RowHash toArray();
}

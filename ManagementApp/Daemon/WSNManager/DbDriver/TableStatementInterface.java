package DbDriver;
import java.util.Iterator;
import App.Countable;
/**
 * Table statement interface
 * 
 * @author Bc. Marcel Gazdik
 * @version 2013-10-21
 */
public interface TableStatementInterface extends Iterable<RowStatement>, Countable {
    
    /**
     * return row at given index or null if index is out of bound
     * 
     * @return RowStatementInterface | null
     * 
     * @throws DbReadException
     */
    RowStatement getRowAt(final int row) throws DbReadException;
    
    /**
     * return next row from current selection or null if pointer is at the end
     * 
     * @return RowStatementInterface | null
     * 
     * @throws DbReadException
     */
    RowStatement getNext() throws DbReadException;
    
    /**
     * return next row from current selection or null if pointer is before first row
     * 
     * @return RowStatementInterface | null
     * 
     * @throws DbReadException
     */
    RowStatement getPrevious() throws DbReadException;
}

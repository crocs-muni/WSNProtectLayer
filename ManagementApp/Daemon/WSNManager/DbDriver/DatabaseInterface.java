package DbDriver;

import java.util.Map;

/**
 * Interface for database communications
 * 
 * @author Bc. Marcel Gazdik 
 * @version 2013-3-11
 */
public interface DatabaseInterface
{
    /**
     * connect to database
     * 
     * @throws DbException
     */
    void connect() throws DbException;
    
    
    /**
     * return data from table
     * 
     * @param String query      sql DML query (SELECT)
     * @param Object ... args   optional variable length data
     * 
     * @retrun  TableStatement
     */
    TableStatement query(final String query, Object ... args) throws DbReadException;
    
    
    /**
     * exec DML operation
     * 
     * @param String execQuery  sql DML query (UPDATE/INSERT/DELETE)
     * @param Object ... args   optional variable length data
     */
    void exec(final String execQuery, Object ... args) throws DbWriteException;
    
    /**
     * begin transaction block
     */
    void beginTransaction() throws DbException;
    
    /**
     * commit changes 
     */
    void rollback() throws DbException;
    
    /**
     * roll back all changes
     */
    void commit() throws DbException;
    
    /**
     * return true if transaction is enabled, false otherwise
     * 
     * @return boolean
     */
    boolean inTransaction();
}

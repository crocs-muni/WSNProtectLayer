/**
 * This file contains NodeList interface
 * 
 * @author 	Bc. Marcel Gazdík
 * @mail:	xgazdi at mail.muni.cz
 */
 
interface NodeListI {
	/**
	 * register new node or update delay if node exists
	 * 
	 * @param nodeid	node id
	 */
	async command void insertOrUpdateNode(uint8_t nodeid);
}
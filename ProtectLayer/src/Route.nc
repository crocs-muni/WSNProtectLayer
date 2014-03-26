/**
 * Interface that provides basic commands necessary for packet forwarding. 
 * 
 * 	@version   0.1
 * 	@date      2012-2013 
 */

#include "ProtectLayerGlobals.h"
interface Route{
	/**
	 * Command that returns the ID of single parent node. 
	 * 
	 * @returns Single parent node ID 
	 */
	command node_id_t getParentID();
	
	/**
	 * Returns random neighbor. Blocking variant.
	 * 
	 * 
	 * @param neigh		random neighbor is provided via this parameter.
	 */
	command error_t getRandomNeighborIDB(node_id_t * neigh);
	
}

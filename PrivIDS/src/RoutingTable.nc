
/** Interface RoutingTable declarates methods for initialization 
 *  and access to items of the routing table. 
 *
 *  @author Mikulas Janos <miki.janos@gmail.com>
 *  @version 1.0 december 2012
 */
interface RoutingTable {
	
	
	command bool amiBS();
	
	command void setBS(bool amiBaseStation);
	
	/** This command cleares routing table.
	 *
	 *  @return void
	 */
	command void init();
	
	/** Signaled in response to completed initialization. 
	 *  Memory allocated by routing table is released.
	 *  error indicates whether the init was successful.  
	 *
	 *  @param  err	 	SUCCESS if init was successfull, FAIL if it was not 
	 *  @return void
	 */
	event void initDone(error_t err);
	
	/** This command returns whether routing table contains neighbor with
	 *  entered adress or not.
	 *
	 *  @param	nbr address of searched neighbor
	 *  @return	TRUE if routing table contains neighbor, FALSE if not
	 */
	 
	command void initKeys();
	
	command bool containsChild(nx_uint16_t nbr);
	
	/** This command adds neighbor to the routing table.
	 *
	 *  @param nbr		neighbor to add
	 *  @param hops		neighbors distance to the base station
	 *  @return void
	 */
	command void addChild(nx_uint16_t nbr);
	
	command void setThresholdIDS(float dropRatio);
	
	command error_t increaseReceiveCount(am_addr_t childId);
	
	command error_t increaseModifCount(am_addr_t childId);
	/** This command returns neighbor address at specified position
	 *  in the routing table. If the position is not occupied by any node, 
	 *  return broadcast address.
	 *  
	 *  @param number	neighbor position
	 *
	 *  @return adress 	of neighbor at specified location in routign table
	 */
	command nx_uint16_t getChildAddress(uint8_t number);
	
	/** 
	 *  @return size of parent part of the routing table
	 */
	command uint8_t parentTableSize();

	/** This command returns presense of parent node with entered adress
	 *  in the routing table.
	 *
	 *  @param	par address of searched parent
	 *  @return	TRUE if routing table contains parent, FALSE if not
	 */
	command bool containsParent(nx_uint16_t par);
	
	/** This command adds parent to the routing table.
	 *
	 *  @param par		parent to add
	 *  @param hops 	distance of parent node to the base station
	 *  @return void
	 */
	command void addToParents(nx_uint16_t par, uint8_t hops);
	/** This command returns parent address at specified position
	 *  in routing table. If the position is not occupied by any node, 
	 *  return broadcast address.
	 *  
	 *  @param number	parent position
	 *  @return adress 	of parent at specified location in routing table
	 */
	command nx_uint16_t getParentAddress(uint8_t number);
	
	command ParentData_t* getParent(nx_uint16_t addr);
	
	command error_t getKey(uint16_t nodeId, uint8_t key_type, PL_key_t** key);
	
	command error_t getKeyValue(uint16_t nodeId, uint8_t key_type, uint8_t key[KEY_LENGTH]);
	
	command error_t getCounter(uint16_t nodeId, uint16_t** counter);
	
	
	command uint8_t getChildIdx(nx_uint16_t nodeId);
	
	command uint8_t getParentIdx(nx_uint16_t nodeId);
	/** 
	 *  @return size of neighbor part of the routing table
	 */
	command uint8_t childTableSize();
	
	/** 
	 *  @return address of the node closest node to the base station, 
     * 	if table is empty return broadcast address
	 */
	command am_addr_t getShortestHop();
	
	/** Clear routing table and release memory allocated by routing table
	 *
	 *  @return void
	 */
	command void clear();	
	
	/** Print out information contained in routing table to RTlog file.
	 *
	 *  @return void
	 */
	command void printOut();
}

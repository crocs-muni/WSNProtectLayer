

/** Component RoutingTableC provides interface RoutingTable. 
 *  RoutingTable consists of two separate "tables". Parent and neighbor table.
 *  One record of table is defined in the header file.
 *  During addition of a node, memory is allocated from the Pool. 
 *  During clearing of routing table, memory allocated by Routing table
 *  is released back to Pool.
 * 
 *  @author Mikulas Janos <miki.janos@gmail.com>
 *  @version 1.0 december 2012
 */
configuration RoutingTableC {
	provides {
		interface RoutingTable;
	}
}
implementation {
	components RoutingTableP;
	
	components SharedDataC;
		
	RoutingTableP.SharedData	-> SharedDataC.SharedData;	
	RoutingTable = RoutingTableP.RoutingTable;

}

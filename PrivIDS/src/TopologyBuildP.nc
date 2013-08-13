#include "TopologyBuild.h"
#include "Timer.h"
/** Component TopologyBuildP implements interface TopologyBuild. 
 *  Topology is build by modificated TinyOS beaconing protocol.
 *  When node receives beacon_msg, then it adds the sender 
 *  of the message to the routing table as a neighbor. If senders distance to 
 *  the base station is lower than current receiver node bs_distance, then 
 *  receiver adds sender node to the routing table as parent and updates 
 *  his current distance to base station. Each node periodically broadcasts 
 *  beacon messages until time to build topology is expired.
 *  For TOSSIM simulation purposes some node needs to be selected as base station.
 *  This is done by beacon_msg (see header file) msg_type. 
 * 	 
 *  @author Jiri Kur, Mikulas Janos <miki.janos@gmail.com>
 *  @version 1.0 december 2012
 */
module TopologyBuildP {
	uses {
   		interface AMSend;
		interface AMPacket;
		interface Packet;
		interface Timer<TMilli> as StopBuildTimer;
		interface Timer<TMilli> as BroadcastTimer; 
		interface RoutingTable;
		interface Receive;
		interface Pool<message_t> as Pool; 
		interface Queue<message_t*> as ReceiveQueue;
	}
	provides {
		interface TopologyBuild;
	}
}

implementation {
	
	uint8_t bs_distance;
	message_t packet;   //beacon to broadcast
	uint8_t state = STATE_INIT;  
	bool busy = FALSE;
	bool isBaseStation;
	bool childHelloToSend = FALSE;
	
	
	
	//initialize local variables and routing table
	command void TopologyBuild.build() {
		dbg("SimulationLog","STATE_INIT Topology build in progress.\n");
		call RoutingTable.init();
		state           = STATE_INIT;
		isBaseStation   = FALSE;
		bs_distance 	= INFINITE;

	}
	
	//fill routing table with values (static topology used in labak testbed)
	event void RoutingTable.initDone(error_t err) {
		if (err == SUCCESS) {
			
		if (TOS_NODE_ID==50)
		{
			isBaseStation = TRUE;
			call RoutingTable.setBS(isBaseStation);
			bs_distance = 0;
		}
			
		switch (TOS_NODE_ID) {
			case 4: { call RoutingTable.addToParents(50,0); call RoutingTable.addChild(41); break; }
			case 5: { call RoutingTable.addToParents(32,1); call RoutingTable.addChild(36); break; }
			case 6: { call RoutingTable.addToParents(50,0); break; }
			case 7: { call RoutingTable.addToParents(37,2); break; }
			case 10: { call RoutingTable.addToParents(50,0); call RoutingTable.addChild(31); break; }
			case 14: { call RoutingTable.addToParents(37,2); call RoutingTable.addChild(15); break; }
			case 15: { call RoutingTable.addToParents(14,3); break; }
			case 17: { call RoutingTable.addToParents(37,2); break; }
			case 19: { call RoutingTable.addToParents(41,2); call RoutingTable.addChild(44); break; }
			case 22: { call RoutingTable.addToParents(30,1); break; }
			case 25: { call RoutingTable.addToParents(50,0); break; }
			case 28: { call RoutingTable.addToParents(31,2); break; }
			case 29: { call RoutingTable.addToParents(50,0); break; }
			case 30: { call RoutingTable.addToParents(50,0); 
					   call RoutingTable.addChild(22);
					   call RoutingTable.addChild(35);
					   call RoutingTable.addChild(37); break; }
			case 31: { call RoutingTable.addToParents(10,1); 
					   call RoutingTable.addChild(28);
					   call RoutingTable.addChild(42); break; }
			case 32: { call RoutingTable.addToParents(50,0); 
					   call RoutingTable.addChild(5);
					   call RoutingTable.addChild(40); break; }
			case 33: { call RoutingTable.addToParents(41,2); break; }
			case 35: { call RoutingTable.addToParents(30,1); break; }
			case 36: { call RoutingTable.addToParents(5,2); break; }
			case 37: { call RoutingTable.addToParents(30,1);
					   call RoutingTable.addChild(7);
					   call RoutingTable.addChild(14);
					   call RoutingTable.addChild(17);
					   call RoutingTable.addChild(43);
					   call RoutingTable.addChild(46);
					   call RoutingTable.addChild(47); break; }
			case 40: { call RoutingTable.addToParents(32,1); break; }
			case 41: { call RoutingTable.addToParents(4,1); 
					   call RoutingTable.addChild(19);
					   call RoutingTable.addChild(33);
					   call RoutingTable.addChild(48); break; }
			case 42: { call RoutingTable.addToParents(31,2); break; }
			case 43: { call RoutingTable.addToParents(37,2); break; }
			case 44: { call RoutingTable.addToParents(19,3); break; }
			case 46: { call RoutingTable.addToParents(37,2); break; }
			case 47: { call RoutingTable.addToParents(37,2); break; }
			case 48: { call RoutingTable.addToParents(41,2); break; }
			case 50: { call RoutingTable.addChild(4);
					   call RoutingTable.addChild(6);
					   call RoutingTable.addChild(10);
					   call RoutingTable.addChild(25);
					   call RoutingTable.addChild(29);
					   call RoutingTable.addChild(30);
					   call RoutingTable.addChild(32); break; }
			} 			
						
			call RoutingTable.initKeys();
			//call RoutingTable.printOut();
			signal TopologyBuild.buildDone(isBaseStation);
		} else {
			call RoutingTable.init();
		}
	}	
	
	
	
	/** When routing tables are build (time to build topology expires), 
         *  deny incomming neighbor beacons, except of rebuild beacons.
         */
	event void StopBuildTimer.fired() {
		
	}
	
	//broadcast child hello to initiate child relation
	event void BroadcastTimer.fired() {
		
	}
	
	
	/** Update beacon msg type and actual distance to BS and post sendBeacon task.
         *  (prepare beacon message to send)
	 */
	
		
    	
	//signaled in response to completed command (call send)
	event void AMSend.sendDone(message_t *msg, error_t error) {
	    	
    	}
    
	//return this nodes current distance to base station
	command uint8_t TopologyBuild.getBSDistance() {
	    	return bs_distance;
	}
	
   
	
	//allocate memory from the Pool for freshly received message and call task to process this message
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
   		
			return msg;	  
	}
		       
}

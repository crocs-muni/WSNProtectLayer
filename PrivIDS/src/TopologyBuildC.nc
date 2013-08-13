#include "TopologyBuild.h"
#include "ProtectLayerGlobals.h"

/** Component TopologyBuildC provides interface TopologyBuild. 
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
 *  @author Mikulas Janos <miki.janos@gmail.com>
 *  @version 1.0 december 2012
 */
configuration TopologyBuildC {
	provides {
		interface TopologyBuild;
	}
}
implementation {
	components TopologyBuildP;
	components new AMSenderC(AM_TOPOLOGYBUILD);	
	components new AMReceiverC(AM_TOPOLOGYBUILD);
	components new TimerMilliC() as StopBuildTimer;
	components new TimerMilliC() as BroadcastTimer;
	components RoutingTableC;
	components new PoolC(message_t, MAX_PARENT_COUNT);
	components new QueueC(message_t*, MAX_PARENT_COUNT);
	
	TopologyBuildP.AMSend 	      -> AMSenderC;
	TopologyBuildP.Receive 	      -> AMReceiverC;
	TopologyBuildP.Packet 	      -> AMSenderC.Packet;
	TopologyBuildP.AMPacket       -> AMSenderC.AMPacket;
	TopologyBuildP.StopBuildTimer -> StopBuildTimer;
	TopologyBuildP.BroadcastTimer -> BroadcastTimer;
	TopologyBuildP.RoutingTable   -> RoutingTableC;
	TopologyBuildP.Pool 	      -> PoolC;
	TopologyBuildP.ReceiveQueue      -> QueueC;
	
	TopologyBuild = TopologyBuildP.TopologyBuild;
}

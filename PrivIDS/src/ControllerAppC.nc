#include "TopologyBuild.h"
#include "ProtectLayerGlobals.h"


/** InitiatorC is the top level configuration.
 *  This component starts Radio and initiates RoutingTable through TopologyBuid.
 *  When the topology is built and routing table is initialized, this component 
 *  proceeds all messages of AM_SENSORDATA AM type. This component also 
 *  periodically generates pre-prepared "sensor" data.
 *  Run timer is started when topology is built. When fired, this component
 *  writes statistics of total packet send/received to log file.
 *  Used routing scheme is defined by wiring to the provider of interface Router.
 *  (BroadcastRouterC, SPRouterC, RWRouterC, DFPRouterC)
 *
 * @author Mikulas Janos <miki.janos@gmail.com>
 */


configuration ControllerAppC {
}
implementation {
	components ControllerAppP, PrivIDSC, UserApp1C;   
   	components PrintfC, SerialStartC;
  
	components MainC;
	components RandomMlcgC;
	components ActiveMessageC;
	components TopologyBuildC;
	components new TimerMilliC() as RunTimer;
	components new TimerMilliC() as BSRunTimer;
	components new TimerMilliC() as RandomDelay;
	components ePIRC;
	components RoutingTableC;
	components PrivacyC;
	components StatsC;

				
	ControllerAppP.Experiment	 -> PrivacyC.Experiment;				
	ControllerAppP.Stats 		 -> StatsC.Stats;
	ControllerAppP.PrivacyInit	 -> PrivacyC.Init;				
	ControllerAppP.Boot          -> MainC;
	ControllerAppP.Random        -> RandomMlcgC;
	ControllerAppP.Init          -> RandomMlcgC;
	ControllerAppP.AMControl     -> ActiveMessageC;
	ControllerAppP.TopologyBuild -> TopologyBuildC;
	ControllerAppP.RunTimer      -> RunTimer;
	ControllerAppP.BSRunTimer    -> BSRunTimer;
	ControllerAppP.RandomDelay   -> RandomDelay;	
	ControllerAppP.ePIRinit		 -> ePIRC.Init;
	ControllerAppP.RoutingTable  -> RoutingTableC.RoutingTable;
	
	MainC.SoftwareInit -> PrivIDSC.Init;	// auto-initialization
	//MainC.SoftwareInit -> UserApp1C.Init;	// auto-initialization
}

#include "TopologyBuild.h"
#include "ProtectLayerGlobals.h"
#include "printf.h"


/**
 *  InitiatorP starts Radio and initiates RoutingTable through TopologyBuid.
 *  When the topology is built and routing table is initialized,this component 
 *  proceeds all messages of AM_SENSORDATA AM type. This component also 
 *  periodically generates "sensor" data (DataGenerator).
 *  (BS)Run timer is started when topology is built. When fired, this component
 *  writes statistics of total packet send/received to log file.
 *  Used routing scheme is defined by wiring to the provider of interface Router.
 *  (BroadcastRouterC, SPRouterC, RWRouterC, DFPRouterC)
 *  Generation of "sensor" data stops when totalGenerated reaches value of maxGenerated.
 *
 *  @author Mikulas Janos <miki.janos@gmail.com>
 */

module ControllerAppP {
	uses {
		interface Boot;
		interface Random;
		interface ParameterInit<uint16_t> as Init;	
		interface SplitControl as AMControl;
		interface TopologyBuild;
		interface Timer<TMilli> as RandomDelay;
		interface Timer<TMilli> as RunTimer;
		interface Timer<TMilli> as BSRunTimer;
		interface Init as ePIRinit;
		interface Init as PrivacyInit;
		interface RoutingTable;
		interface Stats;
		interface Experiment;
	
	}
}
implementation {

	bool topologyBuild;		//TRUE if topology is build, if not then FALSE
	bool isBaseStation;
	message_t packet;
	uint32_t defaultSensorData = 213123;
	uint16_t m_experimentCount = 0;
		
	//start radio with random delay	
	event void Boot.booted() {
		uint16_t delay;
		call Init.init(TOS_NODE_ID);
		delay = call Random.rand16() % 20;
		call RandomDelay.startOneShot(delay);
	} 
	
	event void RandomDelay.fired() {
		call AMControl.start();
		dbg("SimulationLog","Application booted.\n");
	}
	
	
	//initiate TopologyBuild sequence and routing table. Prepare "sensor" data.	
	event void AMControl.startDone(error_t err) {
		
		if (err == SUCCESS) {
			dbg("SimulationLog","Radio ON.\n");
			topologyBuild = FALSE;
			
			call TopologyBuild.build();		
		} else {
			call AMControl.start();		
			dbg("SimulationLog","Unable to start radio. Retrying...\n");
		}
	}
	
	event void AMControl.stopDone(error_t err) {}

	//routing table initiated, topologyBuild section completed
	event void TopologyBuild.buildDone(bool baseStation) {
		topologyBuild = TRUE;
		isBaseStation = baseStation;
			
		call Experiment.startExperiment();
		
		m_experimentCount++;
				
		//call PrivacyInit.init();
		dbg("SimulationLog", "TopologyBuild.buildDone\n");
		
	}

	event void Experiment.ended()
	{
		
		ParentData_t* parent;
		float drop;
		float sent;
		
		
		
		
		parent = call RoutingTable.getParent(0);
		
		drop = (float) call Stats.idsGetMessagesDropped();
		sent = (float) call Stats.idsGetMessagesForwarded();
		
		
		
		//printf("Result: drop %d\n",(int)drop);
		//printf("Result: sent %d\n",(int)sent);
		
		if(drop+sent >= IDS_MIN_SENT)
		{
			if ((sent/(drop+sent) < EXPERIMENT_IDS_THRESHOLD))
				{
					//dropper detected			
					//printf("Result: 1\n");
					call Stats.dropper();
					
				}
			else 
			{ 
				//printf("Result: 0\n");
			}
		} else
		{
			//printf("Result: 0\n");
		}
		//printfflush();
		
		call Stats.printStats();
		call RoutingTable.printOut();
		
		if (m_experimentCount<EXPERIMENT_COUNT)
			{
				call Experiment.startExperiment();
				m_experimentCount++;
			}
				
		
	}
	
	//write statistics to logfile if regular node	
	event void RunTimer.fired() {
		
		//call PrivacyInit.init(); //SIGNAL TEST to stop sending packets	
		call Stats.printStats();
		call RoutingTable.printOut();
		
		dbg("SimulationLog","Simulation stopped\n");
	}

	//write statistics to logfile if base station	
	event void BSRunTimer.fired() {
		
		//call PrivacyInit.init(); //SIGNAL TEST to stop sending packets	
		call Stats.printStats();
		call RoutingTable.printOut();
				
		dbg("SimulationLog","BS:Simulation stopped\n");
	}
		

	event void RoutingTable.initDone(error_t err){
		// TODO Auto-generated method stub
	}
}

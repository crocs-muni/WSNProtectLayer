/**
 * Implementation of routing component. 
 * 	@version   0.1
 * 	@date      2012-2013
 */

#include "ProtectLayerGlobals.h"
module RouteP{
	uses {
		interface SharedData;
		interface Random;
	}
	provides {
		interface Init;
		interface Route;
		}
}
implementation{
	
	//
	//	Init interface
	//
	command error_t Init.init() {
		// TODO: do other initialization
		
                //uint8_t i=0;
		RoutePrivData_t* pTable = call SharedData.getRPrivData();
		
		pTable->isValid = 1;
		switch (TOS_NODE_ID) {
			case 4: { pTable->parentNodeId = 41; break; }
			case 5: { pTable->parentNodeId = 40; break; }
			case 6: { pTable->parentNodeId = 19; break; }
			case 7: { pTable->parentNodeId = 17; break; }
			case 10: { pTable->parentNodeId = 25; break; }
			case 14: { pTable->parentNodeId = 37; break; }
			case 15: { pTable->parentNodeId = 17; break; }
			case 17: { pTable->parentNodeId = 37; break; }
			case 19: { pTable->parentNodeId = 4; break; }
			case 22: { pTable->parentNodeId = 41; break; }
			case 25: { pTable->parentNodeId = 44; break; }
			case 28: { pTable->parentNodeId = 4; break; }
			case 29: { pTable->parentNodeId = 50; break; }
			case 30: { pTable->parentNodeId = 35; break; }
			case 31: { pTable->parentNodeId = 41; break; }
			case 32: { pTable->parentNodeId = 50; break; }
			case 33: { pTable->parentNodeId = 41; break; }
			case 35: { pTable->parentNodeId = 22; break; }
			case 36: { pTable->parentNodeId = 42; break; }
			case 37: { pTable->parentNodeId = 41; break; }
			case 40: { pTable->parentNodeId = 41; break; }
			case 41: { pTable->parentNodeId = 41; break; }
			case 42: { pTable->parentNodeId = 22; break; }
			case 43: { pTable->parentNodeId = 14; break; }
			case 44: { pTable->parentNodeId = 41; break; }
			case 46: { pTable->parentNodeId = 33; break; }
			case 47: { pTable->parentNodeId = 46; break; }
			case 48: { pTable->parentNodeId = 33; break; }
			case 50: { pTable->parentNodeId = 31; break; }
			default: pTable->isValid = 1;
			} 


		return SUCCESS;
	}
	
	//
	// Route interface
	//
	command node_id_t Route.getParentID(){
		combinedData_t* pData = call SharedData.getAllData();
		if (pData->routePrivData.isValid)
		{
			return pData->routePrivData.parentNodeId;
			
		}
		else
		{
			//TODO go through whole table	
		}
		return 0;	//TODO in case no parent found return max value that cannot appear in reality
	}
	
	task void task_getRandomParentID() {
	  	//dbg("NodeState", "KeyDistrib.task_getKeyToBS called.\n");
	  	
		SavedData_t* pTable = call SharedData.getSavedData();
		node_id_t randIndex = call Random.rand16() % MAX_NEIGHBOR_COUNT;
		signal Route.randomParentIDprovided(SUCCESS, pTable[randIndex].nodeId);
	}
	command error_t Route.getRandomParentID(){
		post task_getRandomParentID();
		return SUCCESS;
	}
	
	
	task void task_getRandomNeighborID() {
	  	//dbg("NodeState", "KeyDistrib.task_getKeyToBS called.\n");
		SavedData_t* pTable = call SharedData.getSavedData();
		node_id_t randIndex = call Random.rand16() % MAX_NEIGHBOR_COUNT;
		signal Route.randomNeighborIDprovided(SUCCESS, pTable[randIndex].nodeId);
	}
	command error_t Route.getRandomNeighborID(){
			post task_getRandomNeighborID();
			return SUCCESS;
	}
	/*
	command error_t getParentIDs(node_id_t* ids, uint8_t maxCount);
	
	command error_t getChildrenIDs(node_id_t* ids, uint8_t maxCount);
	
	command error_t getNeighborIDs(node_id_t* ids, uint8_t maxCount);
	*/
	
	

}

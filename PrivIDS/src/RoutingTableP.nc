
#include "ProtectLayerGlobals.h"
#include "printf.h"

/** Component RoutingTableP implements interface RoutingTable. 
 *  RoutingTable consists of two separate "tables". Parent table and neighbor table.
 *  One record of table is defined in the header file.
 *  During addition of a node, memory is allocated from the Pool. 
 *  During clearing of routing table, memory allocated by Routing table
 *  is released back to Pool.
 * 
 *  @author Mikulas Janos <miki.janos@gmail.com>
 *  @version 1.0 december 2012
 */
module RoutingTableP {
	uses {
		interface SharedData;
	}
	provides {
		interface RoutingTable;
	}
}
implementation {

	error_t initSucc;
	
	bool amiBS = FALSE;
	
	ChildData_t* childTable = NULL;
	uint8_t childCount = 0;
	ParentData_t* parentTable = NULL;
	uint8_t parentCount = 0;
	
	
	
	task void initDone();
	
	
	
	command bool RoutingTable.amiBS()
	{
		return amiBS;
	}
	command void RoutingTable.setBS(bool amiBaseStation)
	{
		amiBS=amiBaseStation;
	}
	
	
	/** Release memory allocated by parent part and neighbor part of routing table
	 *  and save table record to log file.
	 */	
	command void RoutingTable.init() {
		
		combinedData_t* sharedData;
		sharedData = call SharedData.getAllData();
		
		childTable = sharedData->childList;
		parentTable = sharedData->parentList;
		
		initSucc = SUCCESS;
		call RoutingTable.clear();
		post initDone();	
	}
	
	
	//signal in response to completed initialization
	task void initDone() {
		signal RoutingTable.initDone(initSucc);
	}
	
	//return TRUE if neighbor with selected address is present in routing table, if not return FALSE
	command bool RoutingTable.containsChild(nx_uint16_t nbr) {
		uint8_t i;
		for(i = 0; i < childCount; i++) {
			if(childTable[i].nodeId == nbr) {
				return TRUE;
			}
		}
		return FALSE;
	}
	
	//return CHILD_NOT_FOUND if child is not in the list, otherwise returns child index
	command uint8_t RoutingTable.getChildIdx(nx_uint16_t nbr) {
		uint8_t i;
		for(i = 0; i < childCount; i++) {
			if(childTable[i].nodeId == nbr) {
				return i;
			}
		}
		return NODE_NOT_FOUND;
	}
	
	
	//allocate memory from the pool for new record	
	command void RoutingTable.addChild(nx_uint16_t nbr) {
		if(!(call RoutingTable.containsChild(nbr)) && 
						childCount < MAX_CHILD_COUNT) {
			childTable[childCount].nodeId = nbr;
			childCount++;
			//dbg("SimulationLog","Neighbor %d added.\n",nbr);
		}
	}
	
	//get address of neighbor at selected position in routing table, if not occupied return broadcast
	command nx_uint16_t RoutingTable.getChildAddress(uint8_t number) {
		ChildData_t* n;
		if (number < childCount) {
			n = &childTable[number];
			return n->nodeId;
		} else {
			return AM_BROADCAST_ADDR;
		}
	}
	
	command void RoutingTable.setThresholdIDS(float dropRatio)
	{
		parentTable[0].thresholdIDS = dropRatio - 0.02;  //make it more tolerant, so subtract 2 %
	}
	
	command error_t RoutingTable.increaseModifCount(am_addr_t childId)
	{
		uint8_t i;
		for(i = 0; i < childCount; i++) {
			if(childTable[i].nodeId == childId) {
				childTable[i].modifCount = childTable[i].modifCount+1;
				return SUCCESS;
			}
		}
		return ENODENOTFOUND;
		
	}
	command error_t RoutingTable.increaseReceiveCount(am_addr_t childId)
	{
		uint8_t i;
		for(i = 0; i < childCount; i++) {
			if(childTable[i].nodeId == childId) {
				childTable[i].receiveCount = childTable[i].receiveCount+1;
				return SUCCESS;
			}
		}
		return ENODENOTFOUND;
		
	}
	//return TRUE if parent with selected address is present in routing table, if not return FALSE
	command bool RoutingTable.containsParent(nx_uint16_t par) {
		uint8_t i;
		for(i = 0; i < parentCount; i++) {
			if((parentTable[i]).nodeId == par) {
				return TRUE;
			}
		}
		return FALSE;
	}
	//return _NOT_FOUND if child is not in the list, otherwise returns child index
	command uint8_t RoutingTable.getParentIdx(nx_uint16_t nbr) {
		uint8_t i;
		for(i = 0; i < parentCount; i++) {
			if(parentTable[i].nodeId == nbr) {
				return i;
			}
		}
		return NODE_NOT_FOUND;
	}
	
	command ParentData_t* RoutingTable.getParent(nx_uint16_t addr) {
		uint8_t i;
		for(i = 0; i < parentCount; i++) {
			if(parentTable[i].nodeId == addr) {
				return &(parentTable[i]);
			}
		}
		return NULL;
	}
	
	//return number of records in neighbor part of routing table
	command uint8_t RoutingTable.childTableSize() {
		return childCount;
	}
	
	//allocate memory from the pool for new record
	command void RoutingTable.addToParents(nx_uint16_t par, uint8_t hops) {
		
		// currently we shall have only single parent
//		if ((parentCount==0) || (parentTable[0].distance > hops))
//			{
//				//add new parent
//				parentTable[0].nodeId = par;
//				parentTable[0].distance = hops;
//				parentCount=1;
//			}
			
		//add new parent
		parentTable[0].nodeId = par;
		parentTable[0].distance = hops;
		parentCount=1;
			
		/*
		if(!(call RoutingTable.containsParent(par)) &&
						 parentCount < MAX_PARENT_COUNT) {
			parentTable->nodeId = par;
			parentTable->distance = hops;
			parentCount++;
	
			//dbg("SimulationLog","Parent %d added.\n",par);
		}
		 */
	}
	
	
	command void RoutingTable.initKeys()
	{
		uint8_t i;
		for(i = 0; i < childCount; i++) {
				
				childTable[i].encKey.keyValue[0]=(childTable[i].nodeId < TOS_NODE_ID) ? childTable[i].nodeId : TOS_NODE_ID;
                childTable[i].encKey.keyValue[1]=(childTable[i].nodeId < TOS_NODE_ID) ? TOS_NODE_ID:childTable[i].nodeId;
                
                childTable[i].macKey.keyValue[0]=(childTable[i].nodeId > TOS_NODE_ID) ? childTable[i].nodeId : TOS_NODE_ID;
                childTable[i].macKey.keyValue[1]=(childTable[i].nodeId > TOS_NODE_ID) ? TOS_NODE_ID:childTable[i].nodeId;
				
			}   
		for(i = 0; i < parentCount; i++) {
				parentTable[i].encKey.keyValue[0]=(parentTable[i].nodeId < TOS_NODE_ID) ? parentTable[i].nodeId : TOS_NODE_ID;
                parentTable[i].encKey.keyValue[1]=(parentTable[i].nodeId < TOS_NODE_ID) ? TOS_NODE_ID:parentTable[i].nodeId;
                
                parentTable[i].macKey.keyValue[0]=(parentTable[i].nodeId > TOS_NODE_ID) ? parentTable[i].nodeId : TOS_NODE_ID;
                parentTable[i].macKey.keyValue[1]=(parentTable[i].nodeId > TOS_NODE_ID) ? TOS_NODE_ID:parentTable[i].nodeId;
			}   
		
	} 
		

	
	
	//get address of parent at selected position in routing table, if not occupied return broadcast		
	command nx_uint16_t RoutingTable.getParentAddress(uint8_t number) {
		ParentData_t* n;
		if (number < parentCount) {
			n = &parentTable[number];
			return n->nodeId;
		} else {
			return AM_BROADCAST_ADDR;
		}
	}

	//return size of parent part of routing table
	command uint8_t RoutingTable.parentTableSize() {
		return parentCount;
	}
	
	//release memory allocated by routing table back to pool	
	command void RoutingTable.clear() {
		uint8_t i;
		for(i=0;i< MAX_PARENT_COUNT;i++) {
			clearParentData(&(parentTable[i]));
		}
		for(i=0;i< MAX_CHILD_COUNT;i++) {
			clearChildData(&childTable[i]);
		}	
	}
	
	//write routing table contents to the journal file		
	command void RoutingTable.printOut() {
		uint8_t i;
		//PrintDbg("RTlog", "RoutingTable.printOut ******************************************************* \n");
		if(childCount==0) {
			//PrintDbg("RTlog","childTable empty.\n");
		} else {
			for(i = 0; i < childCount; i++) {
				printf("Stats: Child %d received %d corrupted %d\n",call RoutingTable.getChildAddress(i), childTable[i].receiveCount, childTable[i].modifCount);
				printfflush();
			}   
		}
		
//		if(parentCount==0) {
//			PrintDbg("RTlog","parentTable empty.\n");
//		} else {
//			for(i = 0; i < parentCount; i++) {
//				PrintDbg("RTlog","Parent no.%d : address %hu dropCount %hu \n",i,call RoutingTable.getParentAddress(i), parentTable[i].dropCount);
//			}   
//		}
	} 


	command error_t RoutingTable.getKey(uint16_t nodeId, uint8_t key_type, PL_key_t** key)
	{
		error_t err = SUCCESS;
		uint8_t idx=0;
		uint8_t i;
		
		idx = call RoutingTable.getChildIdx(nodeId);
		if (idx != NODE_NOT_FOUND)
		{
			switch (key_type)
			{
				case (KEY_ENC):
				{
						*key = &(childTable[idx].encKey);
						break;
				}
				case (KEY_MAC):
				{
						*key = &(childTable[idx].macKey);
						break;
				}
			}
		} else
		{
			idx = call RoutingTable.getParentIdx(nodeId);
			if (idx != NODE_NOT_FOUND)
			{
			switch (key_type)
			{
				case (KEY_ENC):
				{
						*key = &(parentTable[idx].encKey);
						break;
				}
				case (KEY_MAC):
				{
						*key = &(parentTable[idx].macKey);
//						dbg("Privacy","GET_KEY %hhu key_mac: ", idx);
//						for (i=0;i<16;i++)
//						{
//							dbg_clear("Privacy","%hhu ",parentTable[idx].macKey.keyValue[i]);
//						}
//						dbg("Privacy","\n");
						break;
				}
				}
			} else
			{
				//node not found 
				err = EKEYNOTFOUND;
			}
		}
		return err;
		
	}

	command error_t RoutingTable.getKeyValue(uint16_t nodeId, uint8_t key_type, uint8_t key[KEY_LENGTH])
	{
		error_t err = SUCCESS;
		PL_key_t * plkey; 
		uint8_t i;
		
		err = call RoutingTable.getKey(nodeId, key_type, &plkey);
		
		if(err == SUCCESS)
		{
			for (i=0;i<KEY_LENGTH;i++)
			{
				key[i]=(uint8_t)plkey->keyValue[i];
			}
		}
		
		return err;
	}	


	command error_t RoutingTable.getCounter(uint16_t nodeId, uint16_t** counter)
	{
		error_t err = SUCCESS;
		uint8_t idx=0;
		
		idx = call RoutingTable.getChildIdx(nodeId);
		if (idx != NODE_NOT_FOUND)
		{
				*counter = (uint16_t*) &(childTable[idx].counter);
		} else
		{
			idx = call RoutingTable.getParentIdx(nodeId);
			if (idx != NODE_NOT_FOUND)
			{
//				printf("parent index, counter, distance: %d %d %d\n", idx, parentTable[idx].counter, parentTable[idx].distance);
//				printfflush();
			 	*counter = (uint16_t*) &(parentTable[idx].counter);
			} else
			{
				//node not found 
				err = EKEYNOTFOUND;
			}
		}
		return err;
		
		
	}
	
	


	//get address of the node closest to the base station, return broadcast address if table empty	
	command am_addr_t RoutingTable.getShortestHop() {
		/*
		uint8_t i;
		parent* toReturn;
		if(!(call ParentTable.empty())) {
			toReturn = call ParentTable.element(0);
			for(i = 0; i < call ParentTable.size(); i++) {
				if((call ParentTable.element(i))->hop_count < toReturn->hop_count) {
					toReturn = call ParentTable.element(i);
				}
			}
			return toReturn->address;
		} else {
			return AM_BROADCAST_ADDR;       
		}
		*/
		return AM_BROADCAST_ADDR;       
   	}
	

	
}

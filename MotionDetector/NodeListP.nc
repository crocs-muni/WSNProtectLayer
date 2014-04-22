#include "NodeList.h"

module NodeListP {
	provides interface Init;
	provides interface NodeListI;
}
implementation{
	TRNode nodes[MAX_NODES];
	uint8_t pos = 0;
	
	void clearNodes(){
		uint8_t i = 0;
		for(i = 0; i < MAX_NODES; i++){
			nodes[i].nodeid = 0;
			nodes[i].delay = 0;
		}
	}
	
	/**
	 * find node with selected ID, if 
	 */
	/*uint8_t findNode(){
		
	}*/
	
	command error_t Init.init(){
		clearNodes();
		return SUCCESS;
	}
	
	async command void NodeListI.insertOrUpdateNode(uint8_t nodeid){
		//if(nodes[]])
	}
}
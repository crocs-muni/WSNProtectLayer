
/** Interface TopologyBuild declarates methods 
  * for building the network topology. 
  * 	 
  * @author Mikulas Janos <miki.janos@gmail.com>
  * @version 1.0 december 2012
  */
interface TopologyBuild {
	
	/** 
	 *  Initiate local variables and routing tables.
	 *
	 *  @return void
	 */
	command void build();
	
	/** 
	 *  This command returns nodes distance to the base station.
	 *
	 *  @return uint8_t nodes distance to the base station
	 */
	command uint8_t getBSDistance();
	
	/** 
	 *  Signaled after completition of topology build (routing tables initiated). 
	 *
	 *  @param baseStation indicates whether node is the base station 
	 *  @return void
	 */	
	event void buildDone(bool baseStation);
		
}

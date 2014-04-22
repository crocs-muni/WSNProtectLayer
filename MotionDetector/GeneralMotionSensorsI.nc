/**
 * This file contains generic interface for driving motion sensors.
 * 
 * @author 	Bc. Marcel Gazdík
 * @mail:	xgazdi at mail.muni.cz
 */

interface GeneralMotionSensorsI{
	/**
	 * sensor initialization
	 */
	async command void init();
	
	/**
	 * places sensor into low power sleep mode
	 */
	async command void suspend();
	
	/**
	 * return sleep state of sensor
	 * 
	 * @return 	true - sensor is in sleep mode
	 * 			false - sensor is enabled
	 */
	async command bool isSuspended();
	
	/**
	 * Wake up the sensor from sleep mode
	 */
	async command void wakeUp();
	
	/**
	 * start scan sensors neighborhood
	 */
	async command void scan();
	
	/**
	 * Return state of scan procedure
	 * @return	true - scan is running
	 * 			false - scan is done or no scan has been started
	 */
	async command bool isScanning();
	
	
	/**
	 * This event will be signaled when scan is complete
	 * @param	response - contains scan result	
	 */
	event void scanDone(uint8_t response);
}
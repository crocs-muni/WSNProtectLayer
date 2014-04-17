/**
 * This file contains generic interface for driving RFID (etc..) card reader.
 * 
 * @author 	Bc. Marcel Gazdík
 * @mail:	xgazdi at mail.muni.cz
 */

interface GeneralRFIDI{
	/**
	 * card reader initialization
	 */
	async command void init();
	
	/**
	 * send data (command) to card reader (if supported)
	 * returns true on success. If data recieving is
	 * not supported then false will be returned 
	 * at any time..
	 * 
	 * @param uint8_t data	byte to send
	 * @return bool true | false
	 */
	async command bool sendData(uint8_t data);
	
	/**
	 * get received data from reader
	 * 
	 * @return uint16_t 
	 */
	async command uint8_t * getData();
	
	/**
	 * compute data checksum and compare it with given checksum
	 * 
	 * if checksum is correct, then true is returned
	 * 
	 * @return true | false
	 */
	async command bool checkChecksum();
	
	/**
	 * informs about new card
	 */
	event void cardDetected();
	
	/**
	 * shutdown reader or change state to sleep
	 */
	async command void sleep();
	
	/**
	 * wanble / wake up reader
	 */
	async command void wake();
}
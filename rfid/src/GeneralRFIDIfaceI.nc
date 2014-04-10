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
	asnyc command bool sendData(uint8_t data);
	
	/**
	 * get recieved data from reader
	 * 
	 * @return uint16_t 
	 */
	async command uint16_t getData();
}
#include "ProtectLayerGlobals.h"


interface XXTEA{
	//encrypt 64-bit long message using 6 + 52/WORDS rounds with 128-bit key
	//if you want to encrypt longer message change don't forget to change' 'WORDS' correctly
	
	
	 command void MAC(uint8_t *in, uint8_t mac[MAC_LEN], uint8_t *expkey, uint8_t length);
	
	/**
	 * Encrypt one block of plaintext
	 *  @param in the input block of ciphertext.
     *  @param out the resulting block of plaintext. 
     *  @param key an array that contains the key.
	 */
	command void encrypt(uint8_t *inout, uint8_t const key[16]);
	
	/**
	 * Decrypt one block of plaintext
	 *  @param in the input block of ciphertext.
     *  @param out the resulting block of plaintext. 
     *  @param key an array that contains the key.
	 */
	command void decrypt(uint8_t *in, uint8_t *out, uint8_t const key[16]);
	
	/**
     * Encrypt more blocks using CBC mode
     *  @param in the input blocks of ciphertext.
     *  @param out the resulting blocks of plaintext. 
     *  @param key an array that contains the expanded key.
     *  @param length number of blocks in the message
     */
    command void encryptCBC(uint8_t *in_block, uint8_t *out_block, uint8_t *expkey, uint8_t length);
    
    /**
     * Decrypt more blocks using CBC mode
     *  @param in the input blocks of ciphertext.
     *  @param out the resulting blocks of plaintext. 
     *  @param key an array that contains the expanded key.
     * 	@param length number of blocks in the message
     */
    command void decryptCBC(uint8_t *in_block, uint8_t *out_block, uint8_t *expkey,  uint8_t length);
    
    /**
     * Encrypt more blocks using CTR mode
     *  @param in the input blocks of ciphertext.
     *  @param out the resulting blocks of plaintext. 
     *  @param key an array that contains the expanded key.
     * 	@param length number of bytes to process
     */
    command void cryptCTR(uint8_t *inout, uint16_t ctr, uint8_t *expkey,  uint8_t length);
}
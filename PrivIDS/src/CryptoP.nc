/** 
 *  Component providing implementation of Crypto interface.
 *  A module providing actual implementation of Crypto interafce in split-phase manner.
 *  @version   0.1
 * 	@date      2012-2013
 */
#include "ProtectLayerGlobals.h"
#include "printf.h"
module CryptoP {
	uses
	{
		interface XXTEA;
		interface RoutingTable;
		interface Packet;
		interface Timer<TMilli> as CurrentTime;
	}
	provides {
		interface Crypto;
	}
}
implementation
{

	command error_t Crypto.depackMsg(am_addr_t dest, message_t * msg, uint8_t * len, uint8_t nonce[NONCE_LEN]) {
		uint8_t maxPayloadLen = 24;
		uint8_t * payload = (uint8_t * ) call Packet.getPayload(msg, maxPayloadLen);
		uint8_t plaintext[16];
		uint8_t mac[MAC_LEN];
		uint16_t * ctr;
		uint16_t syncCtr;
		uint8_t key_mac[KEY_LENGTH];
		uint8_t key_enc[KEY_LENGTH];
		uint8_t expKey[KEY_LENGTH];
		uint8_t i;
		uint8_t j;
		uint8_t ret;
		//ParentData_t * destNode = NULL;

		//get counter Cxy and key for message decryption Kxy
		call RoutingTable.getKeyValue(dest, KEY_ENC, key_enc);
		call RoutingTable.getCounter(dest, &ctr);
		//destNode = call RoutingTable.getParent(dest);
		//		dbg("Privacy","key_mac: ");
		//		for (i=0;i<16;i++)
		//		{
		//			dbg_clear("Privacy","%hhu ",key_mac->keyValue[i]);
		//		}
		//		dbg("Privacy","\n");
		//		dbg("Privacy","Counter: %hu\n", *ctr);
		//dbg("Privacy","Counter %hu, received from %hu\n", *ctr, dest);
//		printf("depack key_enc: ");
//				for (i=0;i<16;i++)
//				{
//					printf("%d ",key_enc[i]);
//				}
//				printf("\n");
//				printf("Counter for decryption: %d\n", *ctr);
//				printfflush();
		
		
		
//		dbg("Privacy","packet to depack: ");
//				for (i=0;i<19;i++)
//				{
//					dbg_clear("Privacy","%hhu ",payload[i]);
//				}
//				dbg("Privacy","\n");
		
		
		for (i=0;i<COUNTER_SYNC_TRIALS;i++)
		{
			//compute next node nonce (and put it into mac) and expcted MAC
			memcpy(plaintext, payload, NONCE_LEN + MSG_LEN);

//			printf("Privacy ciphertext dec: ");
//				for (j=0;j<16;j++)
//				{
//					printf("%d ",plaintext[j]);
//				}
//				printf("\n");
//				printfflush();
//				
//			printf("Counter for decryption: %d\n", *ctr);
//				printfflush();
			//decryption
			call XXTEA.cryptCTR(plaintext, *ctr, key_enc, NONCE_LEN + MSG_LEN);
	
	
//			printf("Privacy plaintext dec: ");
//				for (j=0;j<16;j++)
//				{
//					printf("%d ",plaintext[j]);
//				}
//				printf("\n");
//				printfflush();
//			dbg("Privacy","plaintext: ");
//				for (j=0;j<11;j++)
//				{
//					dbg_clear("Privacy","%hhu ",plaintext[j]);
//				}
//				dbg("Privacy","\n");
				
	
			//get nonce from the message
			memcpy(nonce, plaintext, NONCE_LEN);
	
			//verify MAC, use nonce as key
			//expand nonce - get key
			memset(expKey, 0, KEY_LENGTH);
			memcpy(expKey, nonce, (NONCE_LEN < KEY_LENGTH) ? NONCE_LEN : KEY_LENGTH);
			call XXTEA.MAC(plaintext + NONCE_LEN, mac, expKey, MSG_LEN);
			ret = memcmp(payload + NONCE_LEN + MSG_LEN, mac, MAC_LEN);
	
			if(ret != 0) {
				//mac verification failed
				dbg("Privacy","MAC verification failed, counter synchronization ...\n");
				//update counter
				*ctr = (*ctr) + 2; //two blocks decrypted	
			}
			else
			{
				break;
			}
			
		}
		//synchronized succesfully?
		if (ret != 0)
		{
			//wrong mac
			//rollback counter
			dbg("Privacy","MAC verification failed, could not synchronize ...\n");
			*ctr = (*ctr)-2*(COUNTER_SYNC_TRIALS);
			
			
//			dbg("Privacy","payload: ");
//				for (i=0;i<19;i++)
//				{
//					dbg_clear("Privacy","%hhu ",payload[i]);
//				}
//				dbg("Privacy","\n");
//				dbg("Privacy"," Counter remains: %hu\n", *ctr);
			
			return EMACNOTVALID;
		}
		

		//copy received msg into payload
		memcpy(payload, plaintext + NONCE_LEN, MSG_LEN);

		//create new nonce
		//get MAC/derivation key
		call RoutingTable.getKeyValue(dest, KEY_MAC, key_mac);
		memcpy(plaintext, ctr, 2);
		memcpy(plaintext + 2, nonce, NONCE_LEN);
		call XXTEA.MAC(plaintext, nonce, (uint8_t*)(key_mac), NONCE_LEN + 2);
		
//		printf("depack key_mac: ");
//				for (i=0;i<16;i++)
//				{
//					printf("%d ",key_mac->keyValue[i]);
//				}
//				printf("\n");
//				printf("Counter: %d\n", *ctr);
//				printfflush();
		
		
		
		//nonce is now ready 
		//dbg("Privacy","Used counter: %hu\n", *ctr);
		//update counter
		*ctr = (*ctr) + 2; //two blocks decrypted	 

		//dbg("Privacy","New counter: %hu\n", *ctr);
		//update payload len
		*len = MSG_LEN;

		return SUCCESS;
	}

	command void Crypto.envelopeMsg(am_addr_t dest, message_t * msg, uint8_t * len,
			uint8_t nonce[NONCE_LEN]) {
		uint8_t maxPayloadLen = 24;
		uint8_t * payload = (uint8_t * ) call Packet.getPayload(msg, maxPayloadLen);
		uint8_t plaintext[16];
		uint8_t mac[MAC_LEN];
		uint16_t * ctr;
		uint8_t key_mac[KEY_LENGTH];
		uint8_t key_enc[KEY_LENGTH];
		uint8_t expKey[KEY_LENGTH];
		uint8_t i;
		ParentData_t * destNode = NULL;

		//get counter and key for mac/nonce derivation
		call RoutingTable.getKeyValue(dest, KEY_MAC, key_mac);
		call RoutingTable.getCounter(dest, &ctr);
		destNode = call RoutingTable.getParent(dest);
//				printf("Privacy key_mac: ");
//				for (i=0;i<16;i++)
//				{
//					printf("%d ",key_mac->keyValue[i]);
//				}
//				printf("\n");
//				printf("Counter: %d\n", *ctr);
//				printfflush();
		//compute next node nonce (and put it into mac) and expcted MAC
		memcpy(plaintext, ctr, 2);
		memcpy(plaintext + 2, nonce, NONCE_LEN);
		
//		dbg("Privacy","counter and nonce: ");
//				for (i=0;i<10;i++)
//				{
//					dbg_clear("Privacy","%hhu ",plaintext[i]);
//				}
//				dbg("Privacy","\n");
		
		
		call XXTEA.MAC(plaintext, mac, (uint8_t*) (key_mac), 2 + NONCE_LEN);

		//expand next node nonce - get key
		memset(expKey, 0, KEY_LENGTH);
		memcpy(expKey, mac, (MAC_LEN < KEY_LENGTH) ? MAC_LEN : KEY_LENGTH);

		call XXTEA.MAC(payload, mac, expKey, MSG_LEN);
		//expected mac stored in mac now
		if(destNode->storeMACptr->isEmpty) {
			//store expected mac and update pointer
			memcpy(destNode->storeMACptr->MAC, mac, MAC_LEN);
			destNode->storeMACptr->timeSent = call CurrentTime.getNow();
			destNode->storeMACptr->isEmpty=FALSE;
			//dbg("Privacy", "CryptoP, storing current time, %zu\n",destNode->storeMACptr->timeSent);
			destNode->storeMACptr = ((destNode->storeMACptr - destNode->expMAC) == EXPECTED_BUFF_LEN - 1 ? destNode->expMAC : destNode->storeMACptr + 1);
		}
		else {
			dbg("Error", "CryptoP, envelopeMsg, expMAC buffer full\n");
			printf("Error, expMAC buffer full\n");
			printfflush();
			//TODO resolve somehow
		}

		// get encryption key
		call RoutingTable.getKeyValue(dest, KEY_ENC, key_enc);
		//		dbg("Privacy","key_enc: ");
		//		for (i=0;i<16;i++)
		//		{
		//			dbg_clear("Privacy","%hhu ",key_enc->keyValue[i]);
		//		}
		//		dbg("Privacy","\n"); 

		// prepare plaintext
		memset(plaintext, 0, 16);
		memcpy(plaintext, nonce, NONCE_LEN);
		memcpy(plaintext + NONCE_LEN, payload, MSG_LEN);

//		dbg("Privacy","new nonce and msg: ");
//				for (i=0;i<11;i++)
//				{
//					dbg_clear("Privacy","%hhu ",plaintext[i]);
//				}
//				dbg("Privacy","\n");
//				printf("Privacy key encrypt: ");
//				for (i=0;i<16;i++)
//				{
//					printf("%d ",key_enc[i]);
//				}
//				printf("\n");
//				printf("Counter for encryption: %d\n", *ctr);
//				printfflush();
//		printf("Privacy plaintext: ");
//				for (i=0;i<16;i++)
//				{
//					printf("%d ",plaintext[i]);
//				}
//				printf("\n");
//				printfflush();

		//encryption, 
		call XXTEA.cryptCTR(plaintext, *ctr, key_enc, NONCE_LEN + MSG_LEN);
		
//		printf("Privacy ciphertext encrypt: ");
//				for (i=0;i<16;i++)
//				{
//					printf("%d ",plaintext[i]);
//				}
//				printf("\n");
		
		// update counter!!!
		//dbg("Privacy","Counter send: %hu to node %hu\n ", *ctr, dest);
		*ctr = (*ctr) + 2;//we have encrypted two blocks - nonce len + msg len + 8 / 8 
		
		//dbg("Privacy","New counter: %hu to send to node %hu\n ", *ctr, dest);
		//add MAC	
		//expand nonce - get key
		memset(expKey, 0, KEY_LENGTH);
		memcpy(expKey, nonce, (NONCE_LEN < KEY_LENGTH) ? NONCE_LEN : KEY_LENGTH);
		// compute MAC
		call XXTEA.MAC(payload, mac, expKey, MSG_LEN);

		//copy into payload 
		memcpy(payload, plaintext, NONCE_LEN + MSG_LEN);
		memcpy(payload + NONCE_LEN + MSG_LEN, mac, MAC_LEN);

//		dbg("Privacy","packet: ");
//				for (i=0;i<19;i++)
//				{
//					dbg_clear("Privacy","%hhu ",payload[i]);
//				}
//				dbg("Privacy","\n");


		//update payload lenght
		(*len) = MSG_LEN + NONCE_LEN + MAC_LEN;

	}


	event void RoutingTable.initDone(error_t err){
		// TODO Auto-generated method stub
	}

	event void CurrentTime.fired(){
		// TODO Auto-generated method stub
	}
}

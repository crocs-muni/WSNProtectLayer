#define DELTA 0x9e3779b9
#define MX (((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (key[(p&3)^e] ^ z)))


//this should be number of words (32-bit) of crypted message
//change it when you want to use longer message than 64 bits
#define WORDS 2

module XXTEAC{
	provides interface XXTEA;
}
implementation{
	
	
	void encryption(uint32_t *out, uint32_t const key[4]) {
	    uint32_t y, z, sum;
	    uint32_t p, rounds, e;     
	    rounds = 6 + 52/WORDS;
	    sum = 0;
	    z = out[WORDS-1];
	    do {
	      sum += DELTA;
	      e = (sum >> 2) & 3;
	      for (p=0; p<WORDS-1; p++) {
	        y = out[p+1]; 
	        z = out[p] += MX;
	      }
	      y = out[0];
	      z = out[WORDS-1] += MX;
	    } while (--rounds);
	}
 
	void decryption(uint32_t *in, uint32_t *out, uint32_t const key[4]) {
     uint32_t y, z, sum;
     uint32_t p, rounds, e;
     memcpy(out, in, WORDS*4); 
      rounds = 6 + 52/WORDS;
      sum = rounds*DELTA;
      y = out[0];
      do {
        e = (sum >> 2) & 3;
        for (p=WORDS-1; p>0; p--) {
          z = out[p-1];
          y = out[p] -= MX;
        }
        z = out[WORDS-1];
        y = out[0] -= MX;
      } while ((sum -= DELTA) != 0);
	}
	
	command void XXTEA.encrypt(uint8_t *inout, uint8_t const key[16]) {
			encryption((uint32_t *)inout,(uint32_t *)key);
		}
		
	command void XXTEA.decrypt(uint8_t *in, uint8_t *out, uint8_t const key[16]) {
			decryption((uint32_t *)in, (uint32_t *)out,(uint32_t *)key);
		}
		
	command void XXTEA.encryptCBC(uint8_t *in_block, uint8_t *out_block, uint8_t *expkey, uint8_t length)
    {
    	uint8_t i;
    	memset(out_block, 0x00, 8);
    	    	
    	for (i = 0; i < 8; i++)
    		{
    			out_block[i] = (uint8_t)(in_block[i] ^ out_block[i]);
    		}
    	
    	call XXTEA.encrypt(out_block, expkey);
    		
    	in_block += 8;
		out_block += 8;
		length -= 1;
    	
    	while (length > 0)
    	{
    		for (i = 0; i < 8; i++)
    		{
    			out_block[i] = (uint8_t)(in_block[i] ^ (out_block - 8)[i]);
    		}
    	
    		call XXTEA.encrypt(out_block, expkey);
    		
    		in_block += 8;
			out_block += 8;
			length -= 1;
    	}
    		
    }
    
    command void XXTEA.decryptCBC(uint8_t *in_block, uint8_t *out_block, uint8_t *expkey, uint8_t length)
    {
    	/*
    	uint8_t i;
    	uint8_t temp2[8];
    	uint8_t temp[8];
    	memset(temp, 0x00, 8);
    	
    	while (length > 0)
    	{
    		memcpy(temp2, in_block, 8);
    		call XXTEA.decrypt(in_block, out_block, expkey);
			
			for(i = 0; i < 8; i++)
			{
				out_block[i] = (uint8_t)(out_block[i] ^ temp[i]);
			}
			
			memcpy(temp, temp2, 8);
			
			in_block += 8;
			out_block += 8;
			length -= 1;
		}
		*/
    		
    }
    
    command void XXTEA.MAC(uint8_t *in, uint8_t mac[MAC_LEN], uint8_t *expkey, uint8_t length)
    {
    	uint8_t i;
    	uint8_t idx=0;
    	uint8_t len=0;
    	uint8_t tmp[MAC_LEN];
    	
    	memset(mac,0,MAC_LEN);
       	    	    	
    	len=length+MAC_LEN;    	    	   	    	
    	while ((len/MAC_LEN) > 0)
    	{
    		len = len-MAC_LEN;
    		memset(tmp,0,MAC_LEN);
    		memcpy(tmp, in+idx, (len>MAC_LEN)?MAC_LEN:len);
    		
    		call XXTEA.encrypt(tmp, expkey);
    		
    		for (i = 0; i < MAC_LEN; i++)
    		{
    			mac[i] = (uint8_t)(mac[i] ^ tmp[i]);
    		}
    		idx = idx+MAC_LEN;
    	}
    }
    
    command void XXTEA.cryptCTR(uint8_t *inout, uint16_t ctr, uint8_t *expkey,  uint8_t length)
    {
    	uint8_t i;
    	uint8_t idx=0;
    	uint8_t counter[8];
    	uint8_t len=0;
    	uint8_t j;
    	uint8_t key[16];
    	
    	    	
    	len=length+8;    	    	   	    	
    	while ((len/8) > 0)
    	{
    		//set counter
    		memset(counter, 0, 8); 
    		counter[6]=(uint8_t)((ctr)>>8);
    		counter[7]=(uint8_t)(ctr & 0xff);
    		ctr=(ctr)+1; 
    		len = len-8;
    		
//    		printf("XXTEA cryptCTR counter: ");
//				for (j=0;j<8;j++)
//				{
//					printf("%d ",counter[j]);
//				}
//				printf("\n");
//			printf("XXTEA cryptCTR key: ");
//				for (j=0;j<16;j++)
//				{
//					printf("%d ",expkey[j]);
//				}
//				printf("\n");	
    		
    		call XXTEA.encrypt(counter, (uint8_t*)expkey);
    		
//    		printf("XXTEA cryptCTR stream: ");
//				for (j=0;j<8;j++)
//				{
//					printf("%d ",counter[j]);
//				}
//				printf("\n");	
    		
    		for (i = 0; i < len && i <8; i++)
    		{
    			inout[idx+i] = (uint8_t)(inout[idx+i] ^ counter[i]);
    		}
    		idx = idx+8;
    	}
   	}
}
// $Id: BlinkToRadioC.nc,v 1.5 2007/09/13 23:10:23 scipio Exp $

/*
 * "Copyright (c) 2000-2006 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 */

/**
 * Implementation of the BlinkToRadio application.  A counter is
 * incremented and a radio message is sent whenever a timer fires.
 * Whenever a radio message is received, the three least significant
 * bits of the counter in the message payload are displayed on the
 * LEDs.  Program two motes with this application.  As long as they
 * are both within range of each other, the LEDs on both will keep
 * changing.  If the LEDs on one (or both) of the nodes stops changing
 * and hold steady, then that node is no longer receiving any messages
 * from the other node.
 *
 * @author Prabal Dutta
 * @date   Feb 1, 2006
 */
#include <Timer.h>
#include <TestCase.h>
#include "BlinkToRadio.h"
#include "ProtectLayerGlobals.h"


module BlinkToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  //uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;


  // Test unit objects	
  uses interface KeyDistrib;
  uses interface Crypto;
  uses interface SharedData;

  uses interface TestControl as SetUp;
  uses interface TestCase as BasicAssertionTest;
  uses interface TestCase as KeyDistrib_sendEncryptedMessage_Test;
  uses interface TestCase as KeyDistrib_decryptMessage_Test;
  uses interface TestCase as KeyDistrib_generateAndDeriveKey_Test;
  uses interface TestCase as KeyDistrib_useKeyToBS_Test;

}
implementation {

  uint16_t counter;
  message_t pkt;
  bool busy = FALSE;
  uint32_t received_packets = 0;
  uint8_t m_resultLen;

  event void SetUp.run() {
      // one-time init - add your action


      call SetUp.done();
  }
  event void BasicAssertionTest.run() {
      assertSuccess();
      assertEquals("uint16_t isn't 2 bytes", 2, sizeof(uint16_t));
      assertTrue("False!", TRUE);
      assertFalse("True!", FALSE);      



      call BasicAssertionTest.done();
  }

  //
  // KeyDistrib_sendEncryptedMessage_Test
  //
  //
  // 1. Discover keys
  // 2. Get Key for neighbor
  // 3. Generate new master key
  // 4. Derive new key
  // 5. Encrypt message for neighbor
  // --
  // 6. Decrypt message from neighbor
  // 7. Get Key for BS
  PL_key_t m_masterKey;
  PL_key_t m_newKey;
  uint8_t  m_buffer[KEY_LENGTH] = {0, 1, 2};
  message_t  m_message;
  uint8_t*   m_payload;
  event void KeyDistrib_sendEncryptedMessage_Test.run() {

      // Introduce two neigbors into tables
      combinedData_t* combinedData = NULL;
      combinedData = call SharedData.getAllData();
      if (combinedData != NULL) {
          combinedData->savedData[0].nodeId = 1;
          combinedData->savedData[1].nodeId = 2;
      }

     // 1. Discover keys
     assertTrue("KeyDistrib.discoverKeys() != SUCCESS", call KeyDistrib.discoverKeys() == SUCCESS);	
  }
  event void KeyDistrib.discoverKeysDone(error_t status) {
     assertEquals("KeyDistrib.discoverKeysDone() != SUCCESS", SUCCESS, status);
     // 2. Get Key for neighbor
     assertTrue("KeyDistrib.getKeyToNode(1) != SUCCESS", call KeyDistrib.getKeyToNode(1) == SUCCESS);	// request key for node with id 1
  }
  event void KeyDistrib.getKeyToNodeDone(error_t status, PL_key_t* pNodeKey) {
     // pNodeKey is stored as masterKey.
     assertEquals("KeyDistrib.getKeyToNodeDone() != SUCCESS", SUCCESS, status);
     if (pNodeKey != NULL) m_masterKey = *pNodeKey;

     // 5. Encrypt message for neighbor
     m_payload = (uint8_t*) (call Packet.getPayload(&m_message, sizeof(BlinkToRadioMsg)));
     assertTrue("Crypto.encryptBuffer(&m_newKey, m_payload, 0, sizeof(BlinkToRadioMsg)) != SUCCESS", call Crypto.encryptBuffer(&m_masterKey, m_payload, 0, sizeof(BlinkToRadioMsg)) == SUCCESS);
  }
  event void Crypto.encryptBufferDone(error_t status, uint8_t* buffer, uint8_t resultLen) {
     assertEquals("KeyDistrib.encryptBufferDone() != SUCCESS", SUCCESS, status);
     m_resultLen = resultLen;
     // We are done!
     call KeyDistrib_sendEncryptedMessage_Test.done();
  }

  //
  // KeyDistrib_decryptMessage_Test
  //
  event void KeyDistrib_decryptMessage_Test.run() {
     m_payload = (uint8_t*) (call Packet.getPayload(&m_message, sizeof(BlinkToRadioMsg)));
     assertTrue("Crypto.decryptBuffer(&m_masterKey, m_payload, 0, resultLen) != SUCCESS", call Crypto.decryptBuffer(&m_masterKey, m_payload, 0, m_resultLen) == SUCCESS);
  }
  event void Crypto.decryptBufferDone(error_t status, uint8_t* buffer, uint8_t resultLen) {
     assertEquals("KeyDistrib.decryptBufferDone() != SUCCESS", SUCCESS, status);
     assertTrue("KeyDistrib.decryptBufferDone() returned unexpected buffer", m_payload == buffer);

     // Prepare encrypted buffer
     assertTrue("Crypto.encryptBufferB(&m_masterKey, m_payload, 0, resultLen) != SUCCESS", call Crypto.encryptBufferB(&m_masterKey, m_payload, 0, &m_resultLen) == SUCCESS);
     // Check for error when different key is used for decryption
     assertTrue("Crypto.decryptBufferB(&m_newKey, m_payload, 0, resultLen) == SUCCESS", call Crypto.decryptBufferB(&m_newKey, m_payload, 0, &m_resultLen) == EDIFFERENTKEY);
     // Check for error when correct key but modified buffer is suplied
     m_payload[0] = 'D';
     assertTrue("Crypto.decryptBufferB(&m_newKey, m_payload, 0, resultLen) == SUCCESS", call Crypto.decryptBufferB(&m_masterKey, m_payload, 0, &m_resultLen) == EINVALIDDECRYPTION);

     // We are done!
     call KeyDistrib_decryptMessage_Test.done();
  }

  //
  // KeyDistrib_useKeyToBS_Test
  //
  event void KeyDistrib_useKeyToBS_Test.run() {
     // Get Key for BS
     assertTrue("KeyDistrib.getKeyToBS() != SUCCESS", call KeyDistrib.getKeyToBS() == SUCCESS);	
  }
  event void KeyDistrib.getKeyToBSDone(error_t status, PL_key_t* pBSKey) {
     assertEquals("KeyDistrib.getKeyToBSDone() != SUCCESS", SUCCESS, status);

     // We are done! 	
     call KeyDistrib_useKeyToBS_Test.done();
  }
 




    event void KeyDistrib_generateAndDeriveKey_Test.run() {
        // Generate new master key
        assertTrue("KeyDistrib.Crypto.generateKey(&m_masterKey) != SUCCESS", call Crypto.generateKey(&m_masterKey) == SUCCESS);	// request new key
        // BUGBUG: Crypto.generateKeyDone should be signaled, but instead Crypto.encryptBufferDone is signaled.
        // Timeout will occur - so prevent it by premature end
    }

    event void Crypto.generateKeyDone(error_t status, PL_key_t* newKey) {
        assertEquals("KeyDistrib.generateKeyDone() != SUCCESS", status, SUCCESS);
        // Derive new key
        assertTrue("Crypto.deriveKey(&m_masterKey, m_buffer, 0, 3, &m_newKey) != SUCCESS", call Crypto.deriveKey(&m_masterKey, m_buffer, 0, 3, &m_newKey) == SUCCESS);	// derive new key
    }
    event void Crypto.deriveKeyDone(error_t status, PL_key_t* derivedKey) {
        assertEquals("KeyDistrib.deriveKeyDone() != SUCCESS", SUCCESS, status);

        // We are done!
        call KeyDistrib_generateAndDeriveKey_Test.done();
     }


















  void setLeds(uint16_t val) {
    if (val & 0x01)
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (val & 0x02)
      call Leds.led1On();
    else
      call Leds.led1Off();
    if (val & 0x04)
      call Leds.led2On();
    else
      call Leds.led2Off();
  }

  event void Boot.booted() {
	call AMControl.start();
	dbg("NodeState", "Node has booted.\n");
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
      dbg("NodeState", "Radio started successfully.\n");
    }
    else {
      call AMControl.start();
      dbg("NodeState", "Radio did not start!\n");
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() {
  	dbg("NodeState", "Timer fired.\n");
    counter++;
    if (!busy) {
      BlinkToRadioMsg* btrpkt = 
	(BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
      if (btrpkt == NULL) {
	return;
      }
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      if (call AMSend.send(AM_BROADCAST_ADDR, 
          &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
  	dbg("NodeState", "Message received.\n");
    if (len == sizeof(BlinkToRadioMsg)) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
      setLeds(btrpkt->counter);
      received_packets++;
      dbg("NodeState", "Sender is: %d, values is: %d.\n", btrpkt->nodeid, btrpkt->counter);
    }
    return msg;
  }
} 

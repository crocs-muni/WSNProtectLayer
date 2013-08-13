/**
 * Java-side application for testing configuration setting via serial port 
 * communication. It prototypes the communication with nodes via serial port.
 *
 * @author Filip Jurnecka
 */

import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class TestConfiguration implements MessageListener {

	private MoteIF moteIF;
	private SavedDataMsg sdMsg = new SavedDataMsg();
	private PPCPrivDataMsg ppcMsg = new PPCPrivDataMsg();
	private LogMsg logMsg = new LogMsg();

	public TestConfiguration(MoteIF moteIF) {
		this.moteIF = moteIF;
		this.moteIF.registerListener(sdMsg, this);
		this.moteIF.registerListener(ppcMsg, this);
		this.moteIF.registerListener(logMsg, this);
	}
	
	public SavedDataMsg getSdMsg() {
		return sdMsg;
	}
	
	public PPCPrivDataMsg getPpcMsg() {
		return ppcMsg;
	}

	public LogMsg getLogMsg() {
		return logMsg;
	}

	public void sendGet() {
		try {

				System.out.println("Logging");
				System.out.println("==========================Sending logger packet==========================");
				FlashGetMsg payload = new FlashGetMsg();
				payload.set_counter(0);
				moteIF.send(0, payload);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}
				
				System.out.println("=======================Press a key to continue======================");
				System.in.read();

				System.out.println("Setting new value for the first neighbour to be node with ID 5");
				System.out.println("==========================Sending packet 0==========================");
				SavedDataMsg payload0 = new SavedDataMsg();
				payload0.set_counter(0);
				payload0.set_savedData_nodeId(5);
				payload0.set_savedDataIdx((short)19);				
				moteIF.send(0, payload0);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}

				System.out.println("=======================Press a key to continue======================");				
				System.in.read();
				
				System.out.println("Printing out initial values (should be all zeros except 19)");
				System.out.println("==========================Sending packet 1==========================");
				GetConfMsg payload1 = new GetConfMsg();
				payload1.set_counter(1);
				moteIF.send(0, payload1);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}
				
				System.out.println("=======================Press a key to continue======================");
				System.in.read();

				System.out.println("Storing initial values to flash");
				System.out.println("==========================Sending packet 2==========================");
				FlashSetMsg payload2 = new FlashSetMsg();
				payload2.set_counter(2);
				moteIF.send(0, payload2);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}

				System.out.println("=======================Press a key to continue======================");				
				System.in.read();
				
				System.out.println("Setting new value for the first neighbour to be node with ID 5");
				System.out.println("==========================Sending packet 3==========================");
				SavedDataMsg payload3 = new SavedDataMsg();
				payload3.set_counter(3);
				payload3.set_savedData_nodeId(5);
				payload3.set_savedDataIdx((short)0);				
				moteIF.send(0, payload3);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}

				System.out.println("=======================Press a key to continue======================");				
				System.in.read();
				
				System.out.println("Printing out all values - first neighbour node should be with ID 5");
				System.out.println("==========================Sending packet 4==========================");
				GetConfMsg payload4 = new GetConfMsg();
				payload4.set_counter(4);
				moteIF.send(0, payload4);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}
				
				System.out.println("=======================Press a key to continue======================");
				System.in.read();

				System.out.println("Restoring initial values from flash");
				System.out.println("==========================Sending packet 5==========================");
				FlashGetMsg payload5 = new FlashGetMsg();
				payload5.set_counter(5);
				moteIF.send(0, payload5);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}
				
				System.out.println("=======================Press a key to continue======================");
				System.in.read();
				
				System.out.println("Setting new value for the seventh and twentieth neighbour to be node with ID 7 and 1");
				System.out.println("=======================Sending packet 6 and 7=======================");
				SavedDataMsg payload6 = new SavedDataMsg();
				payload6.set_counter(6);
				payload6.set_savedDataIdx((short)19);
				payload6.set_savedData_nodeId(1);
				moteIF.send(0, payload6);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}
				SavedDataMsg payload7 = new SavedDataMsg();
				payload7.set_counter(7);
				payload7.set_savedDataIdx((short)6);
				payload7.set_savedData_nodeId(7);
				moteIF.send(0, payload7);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}

				System.out.println("=======================Press a key to continue======================");				
				System.in.read();
				
				System.out.println("Storing new values to flash");
				System.out.println("==========================Sending packet 8==========================");
				FlashSetMsg payload8 = new FlashSetMsg();
				payload8.set_counter(8);
				moteIF.send(0, payload8);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}

				System.out.println("=======================Press a key to continue======================");
				System.in.read();
				
				System.out.println("Setting new value for the sixth and nineteenth neighbour to be node with ID 7 and 1");
				System.out.println("=======================Sending packet 9 and 10=======================");
				SavedDataMsg payload9 = new SavedDataMsg();
				payload9.set_counter(9);
				payload9.set_savedDataIdx((short)5);
				payload9.set_savedData_nodeId(7);
				moteIF.send(0, payload9);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}
				SavedDataMsg payload10 = new SavedDataMsg();
				payload10.set_counter(10);
				payload10.set_savedDataIdx((short)18);
				payload10.set_savedData_nodeId(1);
				moteIF.send(0, payload10);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}

				System.out.println("=======================Press a key to continue======================");
				System.in.read();

				System.out.println("Printing out all values - four neighbours should be set");
				System.out.println("==========================Sending packet 11==========================");
				GetConfMsg payload11 = new GetConfMsg();
				payload11.set_counter(11);
				moteIF.send(0, payload11);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}

				System.out.println("=======================Press a key to continue======================");
				System.in.read();

				System.out.println("Restoring previous values from flash");
				System.out.println("==========================Sending packet 11==========================");
				FlashGetMsg payload12 = new FlashGetMsg();
				payload12.set_counter(12);
				moteIF.send(0, payload12);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
					exception.printStackTrace();
				}
		} catch (IOException exception) {
			System.err.println("Exception thrown when sending packets. Exiting.");
			System.err.println(exception);
		}
	}

	@Override
	public void messageReceived(int to, Message message) {
		System.out.println("Received a message of type \"" + message.getClass().getName() + "\"");
		if (message instanceof SavedDataMsg) {
			SavedDataMsg msg = (SavedDataMsg) message;
		System.out.println("Received packet sequence number "
				+ msg.get_counter() + " " + msg.toString());
		} else if (message instanceof PPCPrivDataMsg) {
			PPCPrivDataMsg msg = (PPCPrivDataMsg) message;
		System.out.println("Received packet sequence number "
				+ msg.get_counter() + " " + msg.toString());
		} else if (message instanceof LogMsg) {
			LogMsg msg = (LogMsg) message;
		System.out.println("Received packet sequence number "
				+ msg.get_counter() + " " + msg.toString());
		}
	}

	private static void usage() {
		System.err.println("usage: TestConfiguration [-comm <source>]");
	}

	public static void main(String[] args) throws Exception {
		String source = null;
		if (args.length == 2) {
			if (!args[0].equals("-comm")) {
				usage();
				System.exit(1);
			}
			source = args[1];
		} else if (args.length != 0) {
			usage();
			System.exit(1);
		}

		PhoenixSource phoenix;

		if (source == null) {
			phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
		} else {
			phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
		}
		
		System.out.println("Running threads at start: " + Thread.activeCount());
		
		MoteIF mif = new MoteIF(phoenix);
		TestConfiguration serial = new TestConfiguration(mif);
		System.out.println("Running threads after start: " + Thread.activeCount());
		serial.sendGet();
		System.out.println("Running threads after sending gets: " + Thread.activeCount());
		mif.deregisterListener(serial.getSdMsg(), serial);
		mif.deregisterListener(serial.getPpcMsg(), serial);
		mif.deregisterListener(serial.getLogMsg(), serial);
		System.out.println("exiting...\nRunning threads: " + Thread.activeCount());
	}

}

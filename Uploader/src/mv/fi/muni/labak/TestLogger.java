package mv.fi.muni.labak;
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
import mv.fi.muni.labak.msg.*;

public class TestLogger implements MessageListener {

	private MoteIF moteIF;
	private LogMsg logMsg = new LogMsg();

	public TestLogger(MoteIF moteIF) {
		this.moteIF = moteIF;
		this.moteIF.registerListener(logMsg, this);
	}
	
	public LogMsg getLogMsg() {
		return logMsg;
	}

	public void requestLog() {
		try {
				System.out.println("==========================Sending logger packet==========================");
				LogMsg payload = new LogMsg();
				payload.set_counter(0);
				payload.set_blockLength((short)20);
				moteIF.send(0, payload);
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
		if (message instanceof LogMsg) {
			/*String s = new String();
			s += "  [data=";
			s += TestLogger.bytesToHex(((LogMsg)message).get_data());
			s += "]\n";*/
			System.out.println(((LogMsg)message).toString());
		} else {
			System.out.println(message.toString());
		}
	}

	private static void usage() {
		System.err.println("usage: TestLogger [-comm <source>]");
	}
	
	public static String bytesToHex(short[] bytes) {
	    final char[] hexArray = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
	    char[] hexChars = new char[bytes.length * 2];
	    int v;
	    for ( int j = 0; j < bytes.length; j++ ) {
	        v = bytes[j] & 0xFF;
	        hexChars[j * 2] = hexArray[v >>> 4];
	        hexChars[j * 2 + 1] = hexArray[v & 0x0F];
	    }
	    return new String(hexChars);
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
		TestLogger serial = new TestLogger(mif);
		System.out.println("Running threads after start: " + Thread.activeCount());
		serial.requestLog();
		System.out.println("Running threads after sending gets: " + Thread.activeCount());
		//mif.deregisterListener(serial.getLogMsg(), serial);
		System.out.println("exiting...\nRunning threads: " + Thread.activeCount());
	}

}

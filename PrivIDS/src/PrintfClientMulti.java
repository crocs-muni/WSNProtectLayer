/* Copyright (c) 2006 Washington University in St. Louis.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @author Kevin Klues (klueska@cs.wustl.edu)
 * @version $Revision: 1.3 $
 * @date $Date: 2010-06-29 22:07:42 $
 */

package net.tinyos.tools;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

import java.io.FileWriter;
import java.io.File;
import java.io.*;
import java.util.*;
import java.io.IOException;


public class PrintfClientMulti implements MessageListener {

  private String filename;
  private MoteIF moteIF;
    
  public PrintfClientMulti(MoteIF moteIF, String fn) {
	    this.moteIF = moteIF;
	    this.moteIF.registerListener(new PrintfMsg(), this);
	    this.filename = fn;
	  }

 
  private static void usage() {
    System.err.println("usage: PrintfClientMulti -list <source>");
  }
  
  public void messageReceived(int to, Message message) {
	  //System.out.println("Message received should be saved to file " + filename);
	    PrintfMsg msg = (PrintfMsg)message;
	    FileWriter fw;
	    try{
	     fw =  new FileWriter(filename,true);
	    
	    for(int i=0; i<PrintfMsg.totalSize_buffer(); i++) {
	      char nextChar = (char)(msg.getElement_buffer(i));
	      if(nextChar != 0)
	    	  fw.write(nextChar);
	    	  //System.out.print(nextChar);
	    }
	    fw.close();
	    }
	    catch (Exception ex) {}
	  }
   
  public static void main(String[] args) throws Exception {  
    String list = null;
    Vector vect = new Vector();
    List lines = null;


    if (args.length == 2) {
      if (!args[0].equals("-list")) {
	       usage();
	       System.exit(1);
      }
    } 
    
    //Path path = FileSystems.getDefault().getPath(args[1]);
    //lines = Files.readAllLines(path, Charset.defaultCharset());
    File file = new File(args[1]);
    BufferedReader br = new BufferedReader(new FileReader(file));
    String line;
    while((line = br.readLine()) != null) {
             // do something with line. 
      String source = "serial@" + line.split("\\s+")[1] + ":telosb";	
      String filename = "output" + line.split("\\s+")[0] + ".txt";
      
      try {
	      PhoenixSource phoenix;  	 
	   	  phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
	   	  
	   	  System.out.print(phoenix);
	   	  MoteIF mif = new MoteIF(phoenix);
	
	   	  PrintfClientMulti pfcm = new PrintfClientMulti(mif,filename);
	    	
	   	  vect.add(pfcm);
      }
      catch (Exception ex) {
    	  //handle exception
      }
   	  Thread.sleep(500);
    }
	    
  }
}

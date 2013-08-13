#! /usr/bin/python
from TOSSIM import *
from sets import Set
import sys




from optparse import OptionParser

parser = OptionParser(usage="usage: %prog [options] filename",
	version="%prog 1.0")

parser.add_option("-g", "--gainfile",
	action="store",
	dest="gainfile",
	default="tossim_tx31.txt",
	help="input file containing gains between nodes")

(options, args) = parser.parse_args()

options_dict = vars(options)

print options_dict['gainfile']


print "Start of the simulation script."

from tinyos.tossim.TossimApp import *
n = NescApp()
vars = n.variables.variables()

t = Tossim(vars)
r = t.radio()
mac = t.mac()

# Configure the topology - the transmitter, the receiver and the gain
f = open(options_dict['gainfile'], "r")

nodes = Set([])

print "Topology:"
lines = f.readlines()
for line in lines:
	s = line.split() # Split line to strings
	if (len(s) > 0):
		if (s[0] == "gain"):
			r.add(int(s[1]), int(s[2]), float(s[3].replace(",",".")))
			print "Source:", s[1], "Destination:", s[2], "Gain:", s[3], "dBm";
			nodes.add(int(s[1]))
			nodes.add(int(s[2]))

print "Number of nodes: " + str(len(nodes)) + ", nodes' ids:", nodes

#t.addChannel("NodeState", sys.stdout)
t.addChannel("Privacy", sys.stdout)

# Sample noise trace
noise = open("fixed_noise.txt", "r")
lines = noise.readlines()
for line in lines:
	strl = line.strip() # Remove whitespace characters
	if (strl != ""):
		val = int(strl)
		for node in nodes:
			t.getNode(node).addNoiseTraceReading(val)

for node in nodes:
	print "Creating noise model for node " + str(node) + "."
	t.getNode(node).createNoiseModel()

# This will make each node starting 5 ms later than the previous one
# (to avoid systematic collisions)
boot_time = 0
for node in nodes:
	t.getNode(node).bootAtTime(0 + boot_time);
	boot_time += 50000000 # equals to 5 ms

# This is example how the inserting of a message can look like:
# Creating a message object using mig is needed.
# from BlinkToRadioMsg import *

# msg = BlinkToRadioMsg()
# msg.set_nodeid(100)
# msg.set_counter(10)
# pkt = t.newPacket();
# pkt.setData(msg.data)
# pkt.setType(msg.get_amType())
# pkt.setDestination(1)

# Deliver to the node 1 in one second from now.
# pkt.deliver(1, t.time() + t.ticksPerSecond())

# This will run the network for 1 second:
time = t.time()
while (time + t.ticksPerSecond()/2 > t.time()):
	t.runNextEvent()

for node in nodes:
	m = t.getNode(node)
	v = m.getVariable("BlinkToRadioC.received_packets")
	received_packets = v.getData()
	print "The node id", node, "has received", received_packets, "in total.";


print "End of the simulation script."

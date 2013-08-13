#! /usr/bin/python
from TOSSIM import *

t = Tossim([])
r = t.radio()

mote0 = t.getNode(0)
mote1 = t.getNode(1)
mote2 = t.getNode(2)
mote3 = t.getNode(3)
mote4 = t.getNode(4)
r.add(1, 0, -65.0)
r.add(0, 1, -65.0)
r.add(2, 1, -65.0)
r.add(1, 2, -65.0)
r.add(3, 2, -65.0)
r.add(2, 3, -65.0)
r.add(4, 3, -65.0)
r.add(3, 4, -65.0)
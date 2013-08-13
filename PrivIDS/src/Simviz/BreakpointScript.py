# 
#    Simviz breakpoint definition file
#
#    We suggest to use "breakpoint" preposition in name of variables 
#    to avoid namespace collisions.
#
#    1.  See TOSSIM tutorial :
#        http://docs.tinyos.net/tinywiki/index.php/TOSSIM
#    2.  Get variable
#        self.tossimNodes["Number of Node"].getVariable(self.appName + "." + "Variable Name")
#    3.  Define condition
#        if "Condition": ...
#    4.  Set variable stop as True, (It will stop the program)
#        step = True
#    5.  Set your output strin to variable: breakpointOutput
#        breakpointOutput = "Breakpoint reached"



""" #    Get "counter" variable from node number: 0
self.breakpointVariable = self.tossimNodes[0].getVariable(self.appName + "." + "counter")
"""


""" #    Stop after "counter" is more than 15
if breakpointVariable.getData() > 15:    
    breakpointOutput = "Breakpoint reached"
    stop = True
"""


""" #    Stop after "counter" is more than before
try:
    if self.breakpointVariable.getData() > self.breakpointCounter:
        self.breakpointCounter = self.breakpointVariable.getData()
        breakpointOutput = "Breakpoint reached"
        stop = True
except:
    breakpointCounter = 0
"""


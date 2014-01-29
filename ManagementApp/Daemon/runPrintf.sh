#!/bin/bash
#
# This script starts Printf clients for all nodes defined in nodelist.
#
# @Author: Ph4r05
#

fname=$1
logdir=$2
reset=$3

# Some sanity checks
if [[ $# -lt 2 || "x$fname" == "x"  || "x$logdir" == "x" ]]
then
	echo "Usage: $0 nodelist logdir [reset-node]"
	echo ""
	echo "   nodelist     List of nodes to listen. One node alias"
	echo "                (e.g. /dev/mote_telos40) per line"
	echo "   logdir       Directory where to place log files"
	echo "   reset        Resets node just before PrintfClient is started"
	echo "                Warning: assumes all connected nodes are TelosB!"
	echo ""
	exit 1
fi

if [ ! -d "$logdir" ]; then
	echo "Logdir $logdir does not exist! I'll try to create it for you dude..."
	mkdir "$logdir" || echo "Sorry, it is not possible..." || exit 2
fi

if [ "x$reset" == "x" ]; then
	reset=0
fi

RCol='\e[0m'   
Red='\e[0;31m';
Gre='\e[0;32m'; 
UBlu='\e[4;34m';

# Main code
nodelist=`cat $fname`
for node in $nodelist; do
	nodefile="$logdir/`basename $node`"
	echo ""
	echo -e "Current node: ${UBlu}$node${RCol} file: $nodefile"
	
	if [ $reset -eq 1 ]; then
		echo -n "Going to reboot node $node                   "
		`which tos-bsl` --telosb -r -c $node &> /dev/null
		RT=$?
		if [ ! $RT -eq 0 ]; then
			echo -e "${Red}Error: ${RCol}Node restart failed"
		else
			echo -e "${Gre}[  OK  ]${RCol}"
		fi
	fi

	echo -n "Going to start PrinfClient on node $node     "	
	java net.tinyos.tools.PrintfClient -comm "serial@$node:telosb" &> $nodefile &
	echo -e "${Gre}[  OK  ]${RCol}"
done


#!/bin/bash

fname=$1
logdir=$2
if [[ "x$fname" == "x"  || "x$logdir" == "x" ]]; then
	echo "Usage: $0 nodelist"
	exit 1
fi

if [ ! -d "$logdir" ]; then
	echo "Logdir $logdir does not exist! I'll try to create it for you dude..."
	mkdir "$logdir" || echo "Sorry, it is not possible..."; exit 2
fi

nodelist=`cat $fname`
echo $nodelist

for node in $nodelist; do
	nodefile="$logdir/`basename $node`"
	echo "current node: $node file $nodefile"
	java net.tinyos.tools.PrintfClient -comm "serial@$node:telosb" 2> $nodefile 1> $nodefile &
done


#!/bin/bash                                                                                                                                                                        
#
# This script extracts node list (aliases) of all connected nodes from motetool output.
#
# @Author: Ph4r05
#

MT=`which motetool`
RT=$?
if [ ! $RT -eq 0 ]; then
	echo -e "Motetool is not installed.\nYou may fix it here: https://github.com/ph4r05/WSNmotelist"
	exit 1
fi

$MT | grep Alias | cut -f 4 -d ';' | cut -f 2 -d ':' |  sed -e 's/^[ \t]*//' | grep -v moteXX


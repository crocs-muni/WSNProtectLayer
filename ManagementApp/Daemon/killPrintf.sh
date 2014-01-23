#!/bin/bash

echo "Going to kill PrintfClient processes.."
pkill -f "net.tinyos.tools.PrintfClient"

echo "Kill seems OK, but just for the case they are still running, I'll try to kill them again"
sleep 5

pkill -9 -f "net.tinyos.tools.PrintfClient"


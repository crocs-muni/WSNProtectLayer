#!/bin/bash

echo "Going to kill TimeStampPrintfClient processes.."
pkill -f "TimeStampPrintfClient"

echo "Kill seems OK, but just for the case they are still running, I'll try to kill them again"
sleep 3

pkill -9 -f "TimeStampPrintfClient"


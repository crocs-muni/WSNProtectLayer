#! /usr/bin/python
import sys
import csv
import os

# Here we start processing of a single csv file containg collected results
def processCsvFile(fToProcess):
	rssiReader = csv.DictReader(open(fToProcess, 'rb'), delimiter=';', quotechar='|')
	txID = fToProcess.split("Tx")[1].split(".")[0]
	print "Transmitting node: " + str(txID)
	rowNumber = 0
	for row in rssiReader:
		rowNumber += 1
		if int(row['plen']) == 16:
			# (twpower / 4) corresponds to the index for the file of results for txpower
			fw[int( row['txpower']) / 4].write("gain " + txID + " " + row['rxnode'] + " " + str(float(row['mean']) - 45) + "\n" )


		
# MAIN starts here:
sourcedir = os.getcwd() + "\\source\\"
resultsdir = os.getcwd() + "\\results\\"

# Here the names of the output files can be changed
foutputs = ['tossim_tx3.txt', 'tossim_tx7.txt', 'tossim_tx11.txt', 'tossim_tx15.txt', 'tossim_tx19.txt', 'tossim_tx23.txt', 'tossim_tx27.txt', 'tossim_tx31.txt']
i = 0
fw = []
for file in foutputs:
	fw.append(open(resultsdir + file, "w"))
	i += 1

# We want to process all files in the sourcedir
for files in os.walk(sourcedir):
	nbFile = 0
	for fsource in files[2]:
		nbFile = nbFile + 1
		fToProcess = sourcedir + fsource
		print "Processing file " + str(nbFile) + ": " + fToProcess
		processCsvFile(fToProcess)
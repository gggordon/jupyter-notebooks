""" Last N Days Time Series Generator  """

# @author ggordon                 
# @created 11.2.2015                 
# @description 
#     Creates last N days data file

import os
import re

NO_OF_DAYS = 7
ItemSKPattern = re.compile('[0-9]{8}')
filePattern=re.compile('product-[0-9]{8}-daily-quantities.csv',re.I)
outputFileName = 'product-%s-%d-day-forecast-data.csv'

def main():
    # Get files in current directory that match pattern
    dataFiles = [ f for f in os.listdir('.') if os.path.isfile(f) and filePattern.match(f) ]

    for filename in dataFiles:
        with open(filename,'r') as file_reader:
            fileContents = file_reader.read()
        records = fileContents.split('\n')
        noOfRecords = len(records)
        print filename,'-',noOfRecords,'records'
        newFileContents = ''
        for i in range(NO_OF_DAYS+1,noOfRecords):
            newFileContents+= ','.join(records[(i-NO_OF_DAYS-1):i])+'\n'

        newFileName = outputFileName % (ItemSKPattern.search(filename).group(0),NO_OF_DAYS)
        print newFileName
        newFile = open(newFileName,'w')
        newFile.write(newFileContents)
        newFile.close()
        print "Saved %d Day Forecast to %s | %d lines" % (NO_OF_DAYS,newFileName,noOfRecords- NO_OF_DAYS+1)

if __name__ == '__main__':
	main()


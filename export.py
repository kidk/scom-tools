#!/usr/bin/env python3

#
# Takes a path as argument to an unsealed management XML file and exports all the scripts to the output directory
#

from xml.dom.minidom import parse
import xml.dom.minidom
import sys
import os

filename = sys.argv[1]
print("Parsing file %s" % (filename))
DOMTree = xml.dom.minidom.parse(filename)
collection = DOMTree.documentElement
datasources = collection.getElementsByTagName("DataSourceModuleType")

print("Creating output directory")
output = os.path.join(os.getcwd(), "export/%s" % (os.path.basename(filename)))
try:
    os.mkdir(output)
except OSError as error:
    print(error)

print("Found %s datasources" % (len(datasources)))
for datasource in datasources:
    name = datasource.getAttribute("ID")
    print(name)
    files = datasource.getElementsByTagName("File")
    for idx, file in enumerate(files):
        filename = file.getElementsByTagName("Name")[0].childNodes[0].data
        print("Exporting content: %s" % (filename))
        print()
        content = file.getElementsByTagName("Contents")[0].childNodes[0].data
        f = open(os.path.join(output, filename), "a")
        f.write(content)
        f.close()

#!/bin/bash
#removes any article XML file from disk unless it is pressent in the given XML. Takes the XML file as argument. Needs to be run from root fo the library.
#ex: . ./bin/crateSubset OWASP.xml

find . | grep "[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}" | while read LINE; do  echo $LINE | awk -F\/ '{print $NF}' | awk -F\. '{print $1}' | xargs -I {} grep {} $1 ; if [ $? -ne 0 ]; then  rm "$LINE"; fi; don

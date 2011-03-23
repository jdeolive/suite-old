#!/bin/bash

if [ "$#" -lt 2 ]
then
    echo './update_version FROM TO'
    exit
fi

FROM="<version>$1<"
TO="<version>$2<"

find . -type f -name pom.xml -exec sed -i "" "s/$FROM/$TO/g" {} \;

echo "Updated version strings in pom.xml files from $1 to $2."

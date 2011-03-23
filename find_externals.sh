#!/bin/bash

for dir in `find . -not \( -name .svn -prune \) -not \( -name target -prune \) -not \( -path '*/externals/*' -prune \) -type d`; do
  if [ -e $dir/.svn ]; then
    svn pl $dir | grep "svn:externals" > /dev/null
    if [ "$?" == "0" ]; then
       if [ "$1" == "-git" ]; then
         echo "pushd $dir"
         for line in `svn pg svn:externals $dir | grep -v "^$" | sed 's/ /;/g' | tr -s '\n' ' '`; do
           arr=( `echo $line | tr -s ';' ' '` )
           loc="${arr[0]}"
           rev=""
           if [ ${#arr[@]} == "3" ]; then
               rev="${arr[1]:2}"
               url="${arr[2]}"
           else
               url="${arr[1]}"
           fi
           
           echo "if [ -d $loc ]; then"
           if [ "$rev" == "" ]; then
              echo "  svn up $loc"
           else
              echo "  svn up -r $rev $loc"
           fi
           echo "else"
           if [ "$rev" == "" ]; then
              echo "  svn co $url $loc"
           else
              echo "  svn co -r $rev $url $loc"
           fi
           echo "fi"
         done

         echo "popd"
       else 
         echo "$dir:"
         svn pg svn:externals $dir | uniq
       fi
    fi
  fi
done

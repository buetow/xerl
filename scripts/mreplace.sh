#!/bin/sh

for j in pm pl xml txt css
do
  for i in `find . -name "*.$j"`
  do
    echo $i
    sed "s/$1/$2/g" $i > temp
    mv -f temp $i
  done 
done 
  

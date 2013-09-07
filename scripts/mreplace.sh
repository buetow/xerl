#!/bin/sh

for j in pm pl xml txt css
do
  for i in `find . -name "*.$j"`
  do
    echo $i
    sed -i "s/$1/$2/g" $i > temp
  done 
done 
  

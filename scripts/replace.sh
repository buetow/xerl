#!/bin/sh

sed "s/$2/$3/g" $1 > temp
mv -f temp $1
  
  

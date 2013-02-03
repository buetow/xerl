#!/bin/bash -x

for i in $(ls *.jpg | grep -v small | grep -v wallpaper); do 
	convert -geometry 210 $i ${i/.jpg/-small.jpg}
done

#!/bin/sh

from="vs.buetow.org"
to="vs-sim.buetow.org"

for log in *.log
do 
	sed "s/$from/$to/" $log > $log.new	
	mv -f $log.new $log
done		


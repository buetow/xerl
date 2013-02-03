#!/bin/bash -x

find . -name \*.inc | while read inc; do
	sed -i -e 's/ü/\&uuml;/g; s/Ü/\&Uuml;/g; s/ö/\&ouml;/g; s/Ö/\&Ouml;/g; s/ä/\&auml;/g; s/Ä/\&Auml;/g; s/ß/\&szlig;/g; s/–/-/g;' $inc
done


all: sums insert

sums:
	for i in `find . -maxdepth 1 -mindepth 1 -type d | grep -v svn`; do \
		echo $$i:; \
		sed -n '/Seiten: / { s/.*>Seiten: \(.*\)<.*/\1/; p; }' $$i/*.inc \
		| awk '{ sum += $$0 } END { print sum }' \
		| tee $$i/seiten.txt; \
	done

insert:
	ls */seiten.txt | while read s; do \
		seiten=`cat $$s`; \
		xml=`dirname $$s`.xml; \
		sed -i "s#<text>Seitenanzahl:.*</text>#<text>Seitenanzahl: $$seiten</text>#" $$xml; \
	done	


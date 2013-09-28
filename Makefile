all:	
replace:
	for i in index.pl Xerl.pm xerl.conf; \
	do \
		sed -n "s/$(FROM)/$(INTO)/g; \
		w .tmp" $$i && mv -f .tmp $$i; \
	done
	find ./Xerl -name '*.pm' -exec sh -c 'sed -n "s/$(FROM)/$(INTO)/g; \
		w .tmp" {} && mv -f .tmp {}' \;
	find ./Xerl -name '*.pl' -exec sh -c 'sed -n "s/$(FROM)/$(INTO)/g; \
		w .tmp" {} && mv -f .tmp {}' \;
	find ./Xerl -name '*.log' -exec sh -c 'sed -n "s/$(FROM)/$(INTO)/g; \
		w .tmp" {} && mv -f .tmp {}' \;
	find ./Xerl -name '*.xml' -exec sh -c 'sed -n "s/$(FROM)/$(INTO)/g; \
		w .tmp" {} && mv -f .tmp {}' \;
	chmod 755 index.pl
perltidy:
	find . -name \*.fpl | xargs perltidy -i=2 -b 
	find . -name \*.pl | xargs perltidy -i=2 -b 
	find . -name \*.pm | xargs perltidy -i=2 -b 
	find . -name \*.bak | xargs rm -f
todo:
	grep -R TODO . | grep -E -v '(\.git|Makefile)' 
warn: 
	perl index.pl 2> warnings
	less warnings
	rm -f warnings
kb:
	find . -name '*.pm' -exec du -hs {} \; | awk 'BEGIN{kb=0}{kb+=$$1}END{print kb}'

all:	
perltidy:
	find . -name \*.fpl | xargs perltidy -i=2 -b 
	find . -name \*.pl | xargs perltidy -i=2 -b 
	find . -name \*.pm | xargs perltidy -i=2 -b 
	find . -name \*.bak | xargs rm -f
todo:
	grep -R TODO . | grep -E -v '(\.git|Makefile)' 

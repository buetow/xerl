#!/bin/sh

# 2006 - 2008 The Xerl Project

for log in *.log
do 
	re=''
	for remove in \
		Charlotte \
		Exabot \
		Mnogo \
		Netcraft \
		Perl \
		Python \
		SurveyBot \
		VoilaBot \
		Yandex \
		Yeti \
		ajSitemap \
		archiver \
		crawler \
		feed \
		findlinks \
		fulltext \
		googlebot \
		grabber \
		jeeves \
		msnbot \
		pear \
		pingdom \
		rss2 \
		sagool \
		sbider \
		slurp \
		spider \
		tagsdir \
		validator \
		walhello \
	;do 
		if [ -z "$re" ]
		then 
			re="($remove)"
		else 
			re="$re|($remove)"
		fi 
	done 
	grep -E -i -v "$re" $log > $log.new	
	mv -f $log.new $log
done		

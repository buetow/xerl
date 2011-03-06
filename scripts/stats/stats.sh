#!/bin/sh

# 2007 (C) Paul C. Buetow (http://paul.buetow.org)

if [ "$1" != "xerl" ]
then
	perl='
 /.*? (.*?) (.*?) /o
   && ++$ip{$2}{$1} && ++$p{$1}
   && ++$h{$2} && ++$t
     for <>;
 $l = do { $_ = length $t; $_ < 4 ? 4 : $_ };
 printf " # %$l"."s%4s %$l"."s%4s %24s\n", 
   "HITS", "%", "UNIQ", "%", "SITE ADDRESS";
 printf "%2.d %$l.d%4.f %$l.d%4.f %24s\n",
   ++$i, $h{$_}, 100*$h{$_}/$t,
   ($n = keys %{$ip{$_}}), 100*$n/(keys %p),$_
     and $i==20 && last
       for sort { $h{$b} <=> $h{$a} } keys %h'
else
	perl='
 /.*? (.*?) (.*?) /o
   && ++$ip{$2}{$1} && ++$p{$1}
   && ++$h{$2} && ++$t
     for <>;
 $l = do { $_ = length $t; $_ < 4 ? 4 : $_ };
 printf "%02.d %0$l.d %02.f %0$l.d %02.f %24s\n",
   ++$i, $h{$_}, 100*$h{$_}/$t,
   ($n = keys %{$ip{$_}}), 100*$n/(keys %p), "!!URL(http://$_)!!"
     and $i==20 && last
       for sort { $h{$b} <=> $h{$a} } keys %h'
fi

#./clean.sh

ls=`ls $path*.log`

cat << STATS
No IP addresses are being logged by Xerl!


Yesterdays top list (pos, total hits, total %, unique hits, unique %):

`echo "$ls" | tail -n 2 | head -n 1 | xargs cat | perl -e "$perl"`

Last 7 days top list (pos, total hits, total %, unique hits, unique %):

`echo "$ls" | tail -n 8 | head -n 7 | xargs cat | perl -e "$perl"`

Last 30 days top list (pos, total hits, total %, unique hits, unique %):

`echo "$ls" | tail -n 31 | head -n 30 | xargs cat | perl -e "$perl"`

Last 365 days top list (pos, total hits, total %, unique hits, unique %):

`echo "$ls" | tail -n 366 | head -n 365 | xargs cat | perl -e "$perl"`

Overall top list (pos, total hits, total %, unique hits, unique %):

`echo "$ls" | xargs cat | perl -e "$perl"`
STATS

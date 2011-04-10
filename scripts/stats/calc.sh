#!/bin/sh
# By Paul C. Buetow (http://www.buetow.org)

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
     and $i==15 && last
       for sort { $h{$b} <=> $h{$a} } keys %h'

ls=`ls *.log`
cat << STATS | less
Weekly top list:

`echo "$ls" | tail -n 7 | xargs cat | perl -e "$perl"`

Monthly top list:

`echo "$ls" | tail -n 28 | xargs cat | perl -e "$perl"`

Yearly top list:

`echo "$ls" | tail -n 356 | xargs cat | perl -e "$perl"`

Forever top list:

`echo "$ls" | xargs cat | perl -e "$perl"`

This stats are powered by Perl, GNU AWK and Bourne Shell
STATS


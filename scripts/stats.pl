#!/usr/bin/perl

# The yChat Project (2003, 2004)
# The Xerl Project (2005, 2006)
#
# This script generates source code and project statistics

use strict;

use scripts::modules::file;

my %stats;
my $param = shift;

recursive('.');

$stats{"Lines total"} =
  $stats{"Lines of source"} +
  $stats{"Lines of scripts"} +
  $stats{"Lines of text"} +
  $stats{"Lines of CSS"} +
  $stats{"Lines of XML"};

unless ( defined $param ) {
    print "$_ = " . $stats{$_} . "\n" for sort keys %stats;

}
else {
    print $stats{$_} . ' ' for sort keys %stats;
}

print "\n";

sub recursive {
    my $shift = shift;
    return unless -d $shift;
    my @dir = dopen($shift);

    foreach (@dir) {
        next if /^\.$/o or /^\.{2}$/o;

        if ( -f "$shift/$_" ) {
            ++$stats{"Number of files total"};
            filestats("$shift/$_");

        }
        elsif ( -d "$shift/$_" ) {
            ++$stats{"Number of dirs total"};
            recursive("$shift/$_");
        }
    }
}

sub filestats {
    my $shift = shift;
    if ( $shift =~ /\.(cpp|h|tmpl)$/o ) {
        ++$stats{"Number of source files"};
        $stats{"Lines of source"} += countlines($shift);

    }
    elsif ( $shift =~ /\.css$/o ) {
        ++$stats{"Number of CSS files"};
        $stats{"Lines of CSS"} += countlines($shift);

    }
    elsif ( $shift =~ /\.(gif|png|jpg)$/o ) {
        ++$stats{"Number of gfx files"};

    }
    elsif ( $shift =~ /(\.xml)$/o ) {
        ++$stats{"Number of XML files"};
        $stats{"Lines of XML"} += countlines($shift);

    }
    elsif ( $shift =~ /(\.pl|\.pm|\.sh|configure.*|Makefile.*)$/o ) {
        ++$stats{"Number of script files"};
        $stats{"Lines of scripts"} += countlines($shift);

    }
    elsif ( $shift =~ /(\.txt|[A-Z]+)$/o ) {
        ++$stats{"Number of text files"};
        $stats{"Lines of text"} += countlines($shift);

    }
    elsif ( $shift =~ /\.so$/o ) {
        ++$stats{"Number of compiled module files"};
    }
}

sub countlines {
    return scalar fopen shift;
}

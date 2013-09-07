#!/usr/bin/perl

use strict;
use warnings;

use Xerl;

use Socket;
use Sys::Hostname;

my $host = hostname();
my $config = -e "configdev-$host.txt" ? "configdev-$host.txt" : (
  -e "config-$host.txt" ? "config-$host.txt" : 'config.txt'
);

my Xerl $xerl = Xerl->new( config => $config );
$xerl->run();

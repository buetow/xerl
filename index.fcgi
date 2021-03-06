#!/usr/bin/perl

# Xerl (c) 2005-2011, 2013-2015 by Paul Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

use strict;
use warnings;

use v5.14.0;
use lib qw(.);

use Xerl;

use FCGI;
use Socket;
use Sys::Hostname;

my $host = hostname();
my $config =
  -e "xerldev.conf"
  ? "xerldev.conf"
  : ( -e "xerl-$host.conf" ? "xerl-$host.conf" : 'xerl.conf' );

while ( FCGI::accept >= 0 ) {
  my $xerl = Xerl->new( config => $config );
  $xerl->run();
}

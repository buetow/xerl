#!/usr/bin/perl

# Xerl (c) 2005-2011, 2013, 2014 by Paul Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

use strict;
use warnings;

use v5.14.0;

use Xerl;

use Socket;
use Sys::Hostname;

my $host = hostname();
my $config =
  -e "xerldev.conf"
  ? "xerldev.conf"
  : ( -e "xerl-$host.conf" ? "xerl-$host.conf" : 'config.conf' );

my $xerl = Xerl->new( config => $config );
$xerl->run();
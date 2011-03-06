#!/usr/bin/perl

use strict;
use warnings;

use Xerl;

my Xerl $xerl = Xerl->new( config => 'config.txt' );
$xerl->run();


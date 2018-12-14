# Xerl (c) 2005-2011, 2013-2015 by Paul Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: https://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl::Setup::Parameter;

use strict;
use warnings;

use v5.14.0;

use Xerl::Base;
use Xerl::Main::Global;
use Xerl::Setup::Configure;
use Xerl::Tools::FileIO;

sub parse {
  my $self   = $_[0];
  my $config = $self->get_config();

  print "Content-Type: text/plain\n\n"
    if $config->plain_exists();

  if ( $config->href_exists() ) {
    print "Location: ", $config->get_href(), "\n\n";
    $config->set_finish_request(1);
  }
  elsif ( $config->env_exists() ) {
    print "Content-Type: text/plain\n\n";
    print "$_=", $ENV{$_}, "\n" for keys %ENV;
    $config->set_finish_request(1);
  }

  if ( $config->devel_exists() ) {
    $config->set_nocache(1);
  }

  if ( $config->conf_exists() ) {
    print "Content-Type: text/plain\n\n";
    print "$_=", $config->{$_}, "\n" for keys %$config;
    $config->set_finish_request(1);
  }

  return $self;
}

1;

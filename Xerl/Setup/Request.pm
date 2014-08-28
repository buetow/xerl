# Xerl (c) 2005-2011, 2013, 2014 by Paul Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl::Setup::Request;

use strict;
use warnings;

use v5.14.0;

use Xerl::Base;

sub parse {
  my $self = $_[0];
  my $request = $self->get_request();

  # Secure it!
  $request =~ s#/\.\.##g;

  # Remove last /
  $request =~ s#/$##;

  my $request_subdir = $request;
  $request_subdir =~ s#/\?.*##;
  $self->set_request_subdir($request_subdir);

  # List context returns $1
  ($_) = $request =~ /\?(.+)/;

  return $self unless defined;

  my $params = '';

  # List context uses ($1,$2) as method args
  for ( split /&/ ) {
    $self->setval(/(.+?)=(.+)/);
    $params .= "&amp;$1=$2" if $1 ne 'site';
  }

  $self->set_params($params);

  return undef;
}

1;


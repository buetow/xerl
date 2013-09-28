# Xerl (c) 2005-2011, 2013 Dipl.-Inform. (FH) Paul C. Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl::Main::Global;

use strict;
use warnings;

use v5.14.0;

sub SHUTDOWN {
  exit 0;

  # Never reach this point
  return undef;
}

sub DEBUG {
  say "Debug::@_";

  return undef;
}

sub ERROR {
  print "Content-Type: text/plain\n\nXerl runtime error: ",
    join( ' ', time, @_ );

  Xerl::Main::Global::SHUTDOWN();

  # Never reach this point
  return undef;
}

sub PLAIN {
  print "Content-Type: text/plain\n\n";

  DEBUG(@_) if @_;

  return undef;
}

sub REDIRECT ($) {
  my $location = shift;

  say "Status: 301 Moved Permanantly";
  print "Location: $location\n\n";

  return undef;
}

sub HTTP {
  my $descr = _HTTP_DESCR(shift);

  print $descr;
  local $, = ' ';
  print $descr;

  Xerl::Main::Global::SHUTDOWN();

  # Never reach this point
  return undef;
}

sub _HTTP_DESCR ($;$) {
  my ( $status, $infomsg ) = @_;

  $infomsg //= '';

  # Sub returns one of the strings below
  if ( $status == 404 ) {
    "Status: 404 Not Found $infomsg\015\012\n\n"

  }
  else {
    "Status: 405 Method not allowed $infomsg\015\012\n\n";
  }
}

1;

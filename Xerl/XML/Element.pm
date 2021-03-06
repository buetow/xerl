# Xerl (c) 2005-2011, 2013-2015 by Paul Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl::XML::Element;

use strict;
use warnings;

use Xerl::Base;

sub starttag {
  my $self = $_[0];
  my ( $name, $temp ) = ( $_[1], undef );

  return $self if $self->get_name() eq $name;
  return undef if ref $self->get_array() ne 'ARRAY';

  for ( @{ $self->get_array() } ) {
    $temp = $_->starttag($name);
    return $temp if defined $temp;
  }

  return undef;
}

sub starttag2 {
  my $self = $_[0];
  my ( $name, $after ) = @_[ 1 ... 2 ];

  my $element = $self->starttag($name);
  return $element->starttag($after) if defined $element;

  return undef;
}

sub params_str {
  my $self   = $_[0];
  my $params = $self->get_params();

  return undef if $params eq '';
  return join '', map { " $_=\"" . $params->{$_} . '"' } keys %$params;
}

1;

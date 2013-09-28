# Xerl (c) 2005-2011, 2013 Dipl.-Inform. (FH) Paul C. Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package UNIVERSAL;

use strict;
use warnings;

use 5.10.0;

use Data::Dumper;

sub new ($;) {
  my $self = shift;

  bless {@_} => $self;
}

sub setval($$$) {
  my UNIVERSAL $self = $_[0];

  $self->{ $_[1] } = $_[2];

  return undef;
}

sub getval($$) {
  my UNIVERSAL $self = $_[0];

  return defined $self->{ $_[1] } ? $self->{ $_[1] } : '';
}

sub exists($$) {
  my UNIVERSAL $self = $_[0];

  return exists $self->{ $_[1] } ? 1 : 0;
}

sub AUTOLOAD {
  my UNIVERSAL $self = $_[0];
  my $auto = our $AUTOLOAD;
  return $self if $auto =~ /DESTROY/;

  if ( $auto =~ /.*::set_(.+)$/ ) {
    $self->{$1} = $_[1];

  }
  elsif ( $auto =~ /.*::get_(.+)_ref$/ ) {
    return defined $self->{$1} ? \$self->{$1} : [''];

  }
  elsif ( $auto =~ /.*::get_(.+)$/ ) {
    return defined $self->{$1} ? $self->{$1} : '';

  }
  elsif ( $auto =~ /.*::undef_(.+)$/ ) {
    return '' unless defined $self->{$1};

    my $retval = $self->{$1};
    undef $self->{$1};
    return $retval;

  }
  elsif ( $auto =~ /.*::append_(.+)$/ ) {
    if ( defined $self->{$1} ) {
      $self->{$1} .= $_[1];

    }
    else {
      $self->{$1} = $_[1];
    }

  }
  elsif ( $auto =~ /.*::push_(.+)$/ ) {
    if ( exists $self->{$1} ) {
      push @{ $self->{$1} }, $_[1];

    }
    else {
      $self->{$1} = [ $_[1] ];
    }

  }
  elsif ( $auto =~ /.*::first_(.+)$/ ) {
    return exists $self->{$1} ? ${ $self->{$1} }[0] : '';

  }
  elsif ( $auto =~ /.*::(.+)_exists$/ ) {
    return exists $self->{$1} ? 1 : 0;

  }
  elsif ( $auto =~ /.*::(.+)_length$/ ) {
    return ( ref $self->{$1} eq 'ARRAY' ) ? scalar @{ $self->{$1} } : 0;

  }
  elsif ( $auto =~ /.*::(.+)_isset$/ ) {
    return exists $self->{$1} ? $self->{ $_[0] } : 0;

  }
  elsif ( $auto =~ /.*::dumper$/ ) {
    say Dumper @_;
    return undef;

  }
  else {
    say "$auto is not a method of $self or UNIVERSAL";
  }

  return $self;
}

1;


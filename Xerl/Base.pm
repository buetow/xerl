# Xerl (c) 2005-2011,2013 Dipl.-Inform. (FH) Paul C. Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of buetow.org nor the names of its contributors may
# 	  be used to endorse or promote products derived from this software
# 	  without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED Paul C. Buetow ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT Paul C. Buetow BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

package UNIVERSAL;

use strict;
use warnings;

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
  else {
    print "$auto is not a method of $self or UNIVERSAL\n";
  }

  return $self;
}

1;


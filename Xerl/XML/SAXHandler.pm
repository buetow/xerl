# Xerl (c) 2005-2011,2013 Dipl.-Inform. (FH) Paul C. Buetow
#
#   E-Mail: xerl@dev.buetow.org   WWW: http://xerl.buetow.org
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
#     be used to endorse or promote products derived from this software
#     without specific prior written permission.
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

package Xerl::XML::SAXHandler;

use base qw(XML::SAX::Base);

use strict;
use warnings;

use 5.10.0;

use Data::Dumper;

use Xerl::Base;
use Xerl::XML::Element;

sub start_document {
  my ($self, $doc) = @_;

  $self->{xerl}{root} = undef;
  $self->{xerl}{current} = undef;
  $self->{xerl}{stack} = [];


  return undef;
}

sub start_element {
  my ($self, $doc) = @_;
  my $x = $self->{xerl};

  if (defined $x->{current}) {
    push @{$x->{stack}}, $x->{current};
    $x->{root} = $x->{current} unless defined $x->{root};
  }

  my %params = map { $_->{Name} => $_->{Value} } values %{$doc->{Attributes}};

  $x->{current} = Xerl::XML::Element->new();
  $x->{current}->set_name($doc->{Name});
  $x->{current}->set_params(\%params) if %params;

  ${$x->{stack}}[-1]->push_array($x->{current}) if @{$x->{stack}};

  return undef;
}

sub characters {
  my ($self, $doc) = @_;
  my $x = $self->{xerl};

  $x->{last_data} = $doc->{Data};

  return undef;
}

sub end_element {
  my ($self, $doc) = @_;
  my $x = $self->{xerl};

  my $prev = pop @{$x->{stack}};
  $prev->{text} = $x->{last_data};
  $x->{current} = $prev;

  return undef;
}

sub end_document {
  my ($self, $doc) = @_;
  my $x = $self->{xerl};

  print Dumper $x->{root};

  return undef;
}

1;

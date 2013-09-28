# Xerl (c) 2005-2011,2013 Dipl.-Inform. (FH) Paul C. Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl::XML::SAXHandler;

use base qw(XML::SAX::Base);

use strict;
use warnings;

use 5.10.0;

use Data::Dumper;

use Xerl::Base;
use Xerl::XML::Element;

sub start_document {
  my ( $self, $doc ) = @_;

  $self->{xerl}{root}    = undef;
  $self->{xerl}{current} = undef;
  $self->{xerl}{stack}   = [];

  return undef;
}

sub start_element {
  my ( $self, $doc ) = @_;
  my $x = $self->{xerl};

  if ( defined $x->{current} ) {
    push @{ $x->{stack} }, $x->{current};
    $x->{root} = $x->{current} unless defined $x->{root};
  }

  my %params = map { $_->{Name} => $_->{Value} } values %{ $doc->{Attributes} };

  $x->{current} = Xerl::XML::Element->new();
  $x->{current}->set_text('');
  $x->{current}->set_name( $doc->{Name} );
  $x->{current}->set_params( \%params ) if %params;

  ${ $x->{stack} }[-1]->push_array( $x->{current} ) if @{ $x->{stack} };

  return undef;
}

sub characters {
  my ( $self, $doc ) = @_;
  my $x = $self->{xerl};

  my $data = $doc->{Data};
  $data =~ s/!!LT!!/</g;
  $data =~ s/!!GT!!/>/g;
  $data =~ s/!!N!!/&/g;

  $x->{current}{text} .= $data;

  return undef;
}

sub end_element {
  my ( $self, $doc ) = @_;
  my $x = $self->{xerl};

  $x->{current} = pop @{ $x->{stack} };

  return undef;
}

1;

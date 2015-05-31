# Xerl (c) 2005-2011, 2013, 2014 by Paul Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: https://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl::XML::Reader;

use strict;
use warnings;

use v5.14.0;

use XML::SAX;

use Xerl::Base;
use Xerl::XML::Element;
use Xerl::XML::SAXHandler;

sub open {
  my $self = shift;

  if ( -f $self->get_path() ) {
    return 0;
  }
  else {
    return 1;
  }
}

sub parse {
  my $self = shift;

  XML::SAX->add_parser(q(XML::SAX::PurePerl));
  my $sax_handler = Xerl::XML::SAXHandler->new();

  my $parser = XML::SAX::ParserFactory->parser( Handler => $sax_handler );
  $parser->parse_uri( $self->get_path() );
  $self->set_root( $sax_handler->{xerl}{root} );

  return undef;
}

1;

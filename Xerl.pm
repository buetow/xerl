# Xerl (c) 2005-2011,2013 Dipl.-Inform. (FH) Paul C. Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same 
# terms as Perl itself.

package Xerl;

use strict;
use warnings;

use CGI::Carp 'fatalsToBrowser';
use Time::HiRes 'gettimeofday';

use Xerl::Base;
use Xerl::Main::Global;
use Xerl::Page::Configure;
use Xerl::Page::Document;
use Xerl::Page::Parameter;
use Xerl::Page::Request;
use Xerl::Page::Templates;

sub run($) {
  my Xerl $self = $_[0];
  my $time = [gettimeofday];

  my Xerl::Page::Request $request =
    Xerl::Page::Request->new( request => $ENV{REQUEST_URI} );

  $request->parse();
  my Xerl::Page::Configure $config =
    Xerl::Page::Configure->new( config => $self->get_config(), %$request );

  $config->parse();
  return undef if $config->finish_request_exists();

  $config->defaults();

  my Xerl::Page::Parameter $parameter =
    Xerl::Page::Parameter->new( config => $config );

  $parameter->parse();
  return undef if $config->finish_request_exists();

  if ( $config->document_exists() ) {
    my Xerl::Page::Document $document =
      Xerl::Page::Document->new( config => $config );

    $document->parse();
    return undef if $config->finish_request_exists();

  }
  else {
    my Xerl::Page::Templates $templates =
      Xerl::Page::Templates->new( config => $config );

    $templates->parse();
    return undef if $config->finish_request_exists();
    $templates->print($time);
  }

  return undef;
}

1;

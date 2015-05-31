# Xerl (c) 2005-2011, 2013-2015 by Paul Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: https://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl;

use strict;
use warnings;

use v5.14.0;

use CGI::Carp 'fatalsToBrowser';
use Time::HiRes 'gettimeofday';

use Xerl::Base;
use Xerl::Main::Global;
use Xerl::Page::Document;
use Xerl::Page::Templates;
use Xerl::Setup::Configure;
use Xerl::Setup::Parameter;
use Xerl::Setup::Request;

sub run {
  my Xerl $self = $_[0];
  my $time = [gettimeofday];

  my $request = Xerl::Setup::Request->new( request => $ENV{REQUEST_URI} );
  $request->parse();

  my $config = Xerl::Setup::Configure->new(
    config => $self->get_config(),
    %$request
  );
  $config->parse();

  return undef if $config->finish_request_exists();

  $config->defaults();

  my $parameter = Xerl::Setup::Parameter->new( config => $config );
  $parameter->parse();
  return undef if $config->finish_request_exists();

  if ( $config->document_exists() ) {
    my $document = Xerl::Page::Document->new( config => $config );
    $document->parse();
    return undef if $config->finish_request_exists();

  }
  else {
    my $templates = Xerl::Page::Templates->new( config => $config );
    $templates->parse();
    return undef if $config->finish_request_exists();
    $templates->print($time);
  }

  return undef;
}

1;

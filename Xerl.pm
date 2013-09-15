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

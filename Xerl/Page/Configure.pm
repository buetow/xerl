# Xerl (c) 2005-2011, Dipl.-Inform. (FH) Paul C. Buetow
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
#     * Neither the name of P. B. Labs nor the names of its contributors may
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

package Xerl::Page::Configure;

use strict;
use warnings;

use Xerl::Base;
use Xerl::Tools::FileIO;
use Xerl::XML::Element;

sub parse($) {
    my Xerl::Page::Configure $self = $_[0];

    my Xerl::Tools::FileIO $file =
      Xerl::Tools::FileIO->new( 'path' => $self->get_config() );

    if (-1 == $file->fslurp()) {
    	$self->set_shutdown(1);
	return undef;
    }

    my $re = qr/^(.+?) *=(.+?) *\n?$/;

    for ( @{ $file->get_array() } ) {
        next if /^ *#/;

        $self->setval( $1, $self->eval($2) ) if $_ =~ $re;
    }

    return $self;
}

sub defaults($) {
    my Xerl::Page::Configure $self = $_[0];

    $self->set_proto('https') if exists $ENV{HTTPS};

    $self->set_site( $self->get_defaultcontent() )
      unless $self->site_exists();

    $self->set_nsite( $self->get_site() =~ /^(?:\d*\.)?(.*)/ );

    $self->set_template( $self->get_defaulttemplate() )
      unless $self->template_exists();

    $self->set_style( $self->get_defaultstyle() )
      unless $self->style_exists();

    $self->set_proto( $self->get_defaultproto() )
      unless $self->proto_exists();

    $self->set_host( lc $ENV{HTTP_HOST} )
      unless $self->host_exists();

    unless ( -d $self->get_hostroot() . $self->get_host() ) {
        my $redirect = $self->get_hostroot() . 'redirect:' . $self->get_host();
        if ( -f $redirect ) {
            my Xerl::Tools::FileIO $file =
              Xerl::Tools::FileIO->new( 'path' => $redirect );
            $file->fslurp();
            my $location = $file->shift();
	    Xerl::Main::Global::REDIRECT( $location );
	    $self->set_shutdown(1);
        }
        my $alias = $self->get_hostroot() . 'alias:' . $self->get_host();
        if ( -f $alias ) {
            my Xerl::Tools::FileIO $file =
              Xerl::Tools::FileIO->new( 'path' => $alias );
            $file->fslurp();
            $self->set_host( $file->shift() );
        }
    }

    $self->set_outputformat( $self->get_defaultoutputformat() )
      unless $self->outputformat_exists();

    if ( $self->format_exists() ) {
        $self->set_outputformat( $self->get_format() );
        $self->set_template( $self->get_format() );
        $self->set_site( $self->get_format() );
        $self->set_nocache(1)
          if $self->get_format() =~ /\.feed$/;
    }

    $self->set_host( $self->getval( $self->get_host() ) )
      if $self->exists( $self->get_host() );

    $self->set_host( $self->getval( $self->get_host() ) )
      if $self->exists( $self->get_host() );

    my $request_subdir = $self->get_request_subdir();
    $self->set_hostpath(
        $self->get_hostroot() . $self->get_host() . $request_subdir . "/" );

    $self->set_defaulthostpath(
        $self->get_hostroot() . $self->get_defaulthost() . '/' );

    $self->set_cachepath(
        $self->get_cacheroot() . $self->get_host() . $request_subdir . '/' );

    $self->set_htdocspath( $self->get_hostpath() . 'htdocs/' );

    $self->set_templatespath( $self->get_hostpath() . 'templates/' );

    $self->set_contentpath( $self->get_hostpath() . 'content/' );

    # $self->set_ipv6( $ENV{REMOTE_ADDR} =~ /:/ ? 1 : 0 );

    return undef;
}

sub eval($$) {
    my Xerl::Page::Configure $self = $_[0];
    my $val = $_[1];

    $val =~ s/^!(.+)/`$1`/eo;
    return $val;
}

sub insertxmlvars($$) {
    my Xerl::Page::Configure $self = $_[0];
    my Xerl::XML::Element $element = $_[1];

    $element = $element->starttag('variables');

    return $self
      unless defined $element
      or $element->get_array() eq 'ARRAY';

    my $text;
    for ( @{ $element->get_array() } ) {
        $text = $_->get_text();
        chomp $text;

        $text =~ s/%%(.*?)%%/$self->getval($1)/eg;
        $self->setval( $_->get_name(), $text );
    }

    return $self;
}

1;


# Xerl (c) 2005-2009, Dipl.-Inform. (FH) Paul C. Buetow
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

package Xerl::Plugins::Session;

use strict;
use warnings;

use CGI;
use CGI::Session;

use Xerl::Base;
use Xerl::Main::Global;
use Xerl::Page::Configure;

sub process($) {
    my Xerl::Plugins::Session $self  = $_[0];
    my Xerl::Page::Configure $config = $self->get_config();

    my CGI $cgi = CGI->new();

    my CGI::Session $session = do {
        my $cookie = $cgi->cookie( -name => 'session' );
        $cookie ? $self->_get_session($cookie) : $self->_create_session();
    };

    $self->set_session($session);

    my @cookievals = split ',', $config->get_cookievals();
    my @ignore = $self->_store_cookie_vals( \@cookievals );
    $self->_restore_cookie_vals( \@cookievals, \@ignore );
    $config->defaults();

    my ( $sessionid, $host ) = ( $session->id(), $config->get_host() );
    print "Set-Cookie: session=$sessionid; domain=$host; path=/\n";

    return undef;
}

sub _create_session($) {
    my Xerl::Plugins::Session $self  = $_[0];
    my Xerl::Page::Configure $config = $self->get_config();

    return CGI::Session->new( 'driver:File', undef );
}

sub _get_session($$) {
    my Xerl::Plugins::Session $self  = $_[0];
    my Xerl::Page::Configure $config = $self->get_config();
    my $cookie                       = $_[1];

    CGI::Session->name($cookie);
    return CGI::Session->new( 'driver:File', $cookie );
}

sub _store_cookie_vals($$) {
    my Xerl::Plugins::Session $self  = $_[0];
    my Xerl::Page::Configure $config = $self->get_config();
    my CGI::Session $session         = $self->get_session();
    my $cookievals                   = $_[1];

    my @set;

    for my $key (@$cookievals) {
        if ( $config->exists($key) ) {
            my $val = $config->getval($key);
            $session->param( $key => $val );
            push @set, $key;

        }
        elsif ( $config->exists("not$key") ) {
            $session->clear($key);
            push @set, "not$key";
        }
    }

    return grep !/\.feed/, @set;
}

sub _restore_cookie_vals($$$) {
    my Xerl::Plugins::Session $self  = $_[0];
    my Xerl::Page::Configure $config = $self->get_config();
    my CGI::Session $session         = $self->get_session();
    my ( $cookievals, $ignore ) = @_[ 1 .. 2 ];

  KEY: for my $key (@$cookievals) {
        for my $ig (@$ignore) {
            next KEY if $key eq $ig;
        }

        if ( defined( my $val = $session->param($key) ) ) {
            $val =~ s#/\.\.##g;
            $config->setval( $key => $val ) if $val;
        }
    }

    return undef;
}

1;


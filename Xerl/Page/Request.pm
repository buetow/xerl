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

package Xerl::Page::Request;

use strict;
use warnings;

use Xerl::Base;

sub parse($) {
    my Xerl::Page::Request $self = $_[0];
    my $request = $self->get_request();

    # Secure it!
    $request =~ s#/\.\.##g;

    # Remove last /
    $request =~ s#/$##;

    my $request_subdir = $request;
    $request_subdir =~ s#/\?.*##;
    $self->set_request_subdir($request_subdir);

    # List context returns $1
    ($_) = $request =~ /\?(.+)/;

    return $self unless defined;

    my $params = '';
    for ( split /&/ ) {

        # List context uses ($1,$2) as method args
        $self->setval(/(.+?)=(.+)/);
        $params .= "&amp;$1=$2" if $1 ne 'site';
    }

    $self->set_params($params);

    return undef;
}

1;


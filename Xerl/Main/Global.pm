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

package Xerl::Main::Global;

sub SHUTDOWN {
    exit 0;

    # Never reach this point
    return undef;
}

sub DEBUG {
    print 'Debug::', @_, "\n";

    return undef;
}

sub ERROR {
    print "Content-Type: text/plain\n\nXerl runtime error: ",
      join( ' ', time, @_ );

    Xerl::Main::Global::SHUTDOWN();

    # Never reach this point
    return undef;
}

sub PLAIN {
    print "Content-Type: text/plain\n\n";

    DEBUG(@_) if @_;

    return undef;
}

sub REDIRECT ($) {
    my $location = shift;
    print "Status: 301 Moved Permanantly\n";
    print "Location: $location\n\n";
    return undef;
}

sub _HTTP_DESCR ($;$) {
    my ($status, $infomsg) = @_;

    $infomsg //= '';

    if ( $status == 404 ) {
        "Status: 404 Not Found $infomsg\015\012\n\n"

    }
    else {
        "Status: 405 Method not allowed $infomsg\015\012\n\n";
    }
}

sub HTTP {
    my $descr = _HTTP_DESCR(shift);
    print $descr;
    local $, = ' ';
    print $descr;

    Xerl::Main::Global::SHUTDOWN();

    # Never reach this point
    return undef;
}

1;

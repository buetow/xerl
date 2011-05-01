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

package Xerl::Page::Document;

use strict;
use warnings;

use Xerl::Base;
use Xerl::Main::Global;
use Xerl::Page::Configure;
use Xerl::Tools::FileIO;

sub parse($) {
    my Xerl::Page::Document $self    = $_[0];
    my Xerl::Page::Configure $config = $self->get_config();

    return undef unless $config->document_exists();

    my $document = $config->get_document();
    my ($filename) = $document =~ m#([^/]+)$#;
    my ($postfix)  = $document =~ /\.(.+)$/;
    my $path;

    print 'Content-Type: ';
    print $config->getval( 'ctype.' . lc($postfix) ), "\n";
    print "Content-Disposition: attachment; filename=\"$filename\"\n\n";

    $path = $config->get_hostpath() . "/htdocs/$document";
    unless ( -f $path ) {
        $path =
            $config->get_hostroot()
          . $config->get_defaulthost()
          . "/htdocs/$document";
    }

    my Xerl::Tools::FileIO $io = Xerl::Tools::FileIO->new( path => $path );

    if ( -1 == $io->fslurp() ) {
        $config->set_finish_request(1);
    }
    else {
        $io->print();
    }

    return undef;
}

1;

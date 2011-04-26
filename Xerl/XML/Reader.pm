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

package Xerl::XML::Reader;

use strict;
use warnings;

use Xerl::Base;
use Xerl::XML::Element;

sub open($) {
    my Xerl::XML::Reader $self = $_[0];

    my Xerl::Tools::FileIO $xmlfile =
      Xerl::Tools::FileIO->new( path => $self->get_path() );

    return -1 if -1 == $xmlfile->fslurp();
    $self->set_array( $xmlfile->get_array() );

    return undef;
}

sub parse($) {
    my Xerl::XML::Reader $self = $_[0];

    my $rarray = $self->get_array();
    return $self unless ref $rarray eq 'ARRAY';

    my Xerl::XML::Element $element = Xerl::XML::Element->new();
    my Xerl::XML::Element( $root, $next, $prev, $insert );

    # Prove and remove XML Header.
    Xerl::Main::Global::ERROR( 'No valid XML header', caller() )
      unless $rarray->[0] =~ s/<\?xml .*?version.+?\?>//io;

    my ( $newlineadd, $linecount, $notrim ) = ( 0, 0, 0 );

    #for my $line (@$rarray) {
    for my $line (@$rarray) {
        $newlineadd = 1 if length $line == 1 and $linecount > 3;
        ++$linecount;

        $line =~ s/\\</!!LT!!/g;
        $line =~ s/\\>/!!GT!!/g;

        # Allow <tag />
        my $is_single_tag = $line =~ s#<([^/].+?)( (.*?))? ?/ *>#<$1 $3></$1>#o;

        # Open XML tag
        if ( $line =~ s#<([^/].+?)( (.*?))? *>##o ) {
            my ( $name, $params ) = ( $1, $3 );

            # Ignore XML comments
            next if $name =~ /^!--/o;

            $next = Xerl::XML::Element->new();
            $next->set_name($name);
            $next->set_prev($element);
            $next->set_single($is_single_tag);

            # Handle tag parameters
            if ( defined $params ) {
                my %params = $params =~ /
      		(?: ( [^\s]+? ) \s*=\s* ( 
			(?: '(?:.|(?:\\'))*?' ) | 
			(?: "(?:.|(?:\\"))*?" ) | 
			(?: [^\s]+ ) ) ) 
		/gox;

                # Remove " and '
                $params{$_} =~ s/^(?:"|')|(?:"|')$//go for keys %params;
                $next->set_params( \%params );
                $notrim = 1 if exists $params{notrim};
            }

            $element->push_array($next);

            $root    = $element unless defined $root;
            $element = $next;
            $insert  = $element;

            redo;
        }

        # Close XML tag
        if ( $line =~ s#<(/.+?)>##o ) {

            #print "XML::<$1>\n";
            if ( $element->get_name() eq 'includefiles' ) {
                my $config = $self->get_config();
                my $params = $element->get_params();
                my $path =
                  $config->get_hostpath() . 'content/' . $params->{reldir};
                my $pattern = $params->{pattern};
                my $maxitems =
                  exists $params->{maxitems} ? $params->{maxitems} : 100;
                my $startindex =
                  exists $params->{startindex} ? $params->{startindex} : 0;

                my Xerl::Tools::FileIO $io =
                  Xerl::Tools::FileIO->new( path => $path );

                $io->dslurp();
                $io->reverse_array() if exists $params->{reversed};

                for my $include ( grep { /$pattern/o } @{ $io->get_array() } ) {
                    last unless $maxitems--;
                    next if 0 < $startindex--;

                    my Xerl::XML::Reader $reader = Xerl::XML::Reader->new(
                        path   => $include,
                        config => $config
                    );

                    if (-1 == $reader->open()) {
			$config->set_shutdown(1);
			return undef;
		    }
                    $reader->parse();

                    my Xerl::XML::Element $starttag =
                      $reader->get_root()->starttag('content');

                    my $sep =
                      exists $params->{separator}
                      ? $params->{separator}
                      : 'noop';
                    $starttag->set_name($sep);
                    $element->set_name('noop');
                    $element->push_array($starttag);
                }
            }

            $insert  = $element;
            $prev    = $element->get_prev();
            $element = $prev if defined $prev;
            $notrim  = 0 if $notrim;

            redo;
        }

        # XML text
        if ( defined $insert
            and $line =~ s/^( *)(.+?) *$/$notrim ? $1.$2 : $2/oe )
        {

            if ($newlineadd) {
                $insert->append_text("\n");
                $newlineadd = 0;
            }

            $line =~ s/!!LT!!/</g;
            $line =~ s/!!GT!!/>/g;

            $insert->append_text($line);
        }
    }

    $root->set_name('root');

    # $root->print();
    $self->set_root($root);

    return undef;
}

1;

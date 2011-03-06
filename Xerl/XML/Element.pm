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

package Xerl::XML::Element;

use strict;
use warnings;

use Xerl::Base;

sub starttag($$) {
    my Xerl::XML::Element $self = $_[0];
    my ( $name, $temp ) = ( $_[1], undef );

    return $self if $self->get_name() eq $name;
    return undef if ref $self->get_array() ne 'ARRAY';

    for ( @{ $self->get_array() } ) {
        $temp = $_->starttag($name);
        return $temp if defined $temp;
    }

    return undef;
}

sub starttag2($$$) {
    my Xerl::XML::Element $self = $_[0];
    my ( $name, $after ) = @_[ 1 ... 2 ];

    my Xerl::XML::Element $element = $self->starttag($name);
    return $element->starttag($after) if defined $element;

    return undef;
}

sub params_str($) {
    my Xerl::XML::Element $self = $_[0];
    my $params = $self->get_params();

    return if $params eq '';

    return join '', map { " $_=\"" . $params->{$_} . '"' } keys %$params;
}

# Only for testing
sub print($) {
    my Xerl::XML::Element $self = $_[0];
    print $self. "::print(\$)\n";

    my $sub;
    $sub = sub {
        my ( $element, $spaceing ) = @_;
        my $spaces = ' ' x $spaceing;

        print $spaces, '<', $element->get_name(), ">\n";
        print "$spaces [$_=", _no_newline( $$element{$_} ), "]\n"
          for keys %$element;

        #if ($element->exists('params')) {
        if ( $element->params_exists() ) {
            print "$spaces Params:\n";
            while ( my ( $key, $val ) = each %{ $element->get_params() } ) {
                print "$spaces  $key=$val\n";
            }
        }

        return unless ref $element->get_array() eq 'ARRAY';
        $sub->( $_, $spaceing + 1 ) for @{ $element->get_array() };
    };

    $sub->( $self, 0 );
    print $self. "::print(\$)::END\n";

    return undef;
}

sub _no_newline($) {
    my $line = $_[0];

    $line =~ s/\n//g;

    return $line;
}

1;

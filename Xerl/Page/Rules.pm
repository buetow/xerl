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

package Xerl::Page::Rules;

use strict;
use warnings;

use Xerl::Base;
use Xerl::XML::Element;
use Xerl::Page::Configure;

sub parse($) {
  my Xerl::Page::Rules $self       = $_[0];
  my Xerl::XML::Element $element   = $_[1];
  my Xerl::Page::Configure $config = $self->get_config();

  $element = $element->starttag2( 'rules', $config->get_outputformat() );
  return unless defined $element;

  # Open and close rules:
  my ( $orule, $crule );

  # For all available rules in config.xml
  for my $rule ( @{ $element->get_array() } ) {
    my $params = $rule->get_params();

    $orule = $rule->get_text();
    chomp $orule;

    $orule =~ s/\[/</go;
    $orule =~ s/\]/>/go;

    unless (
      ref $params eq 'HASH'
      && ( lc $params->{end} eq 'yes'
        || lc $params->{start} eq 'yes' )
      )
    {
      $crule = join '><', reverse split /> *</, $orule;
      $crule = "<$crule>";
      $crule =~ s/<</</go;
      $crule =~ s/>>/>/go;
      $crule =~ s/</<\//go;
      $crule =~ s/\n//go;
      $crule =~ s/ .+?>/>/go;
      $crule .= "\n";

    }
    else {
      if ( lc $$params{start} eq 'yes' ) {
        $crule = '';

      }
      else {
        $crule = $orule;
        $orule = '';
      }
      $crule .= "\n";
    }

    $params = {} unless ref $params eq 'HASH';
    $self->setval( $rule->get_name(), [ "$orule\n", $crule, $params ] );
  }

  return undef;
}

1;

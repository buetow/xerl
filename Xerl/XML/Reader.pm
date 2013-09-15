# Xerl (c) 2005-2011,2013 Dipl.-Inform. (FH) Paul C. Buetow
#
#   E-Mail: xerl@dev.buetow.org   WWW: http://xerl.buetow.org
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
#     be used to endorse or promote products derived from this software
#     without specific prior written permission.
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

use XML::SAX;

use Xerl::Base;
use Xerl::XML::Element;
use Xerl::XML::SAXHandler;

sub open($) {
  my Xerl::XML::Reader $self = $_[0];

  my Xerl::Tools::FileIO $xmlfile =
    Xerl::Tools::FileIO->new( path => $self->get_path() );

  return -1 if -1 == $xmlfile->fslurp();
  $self->set_array( $xmlfile->get_array() );

  return 0;
}

sub sax() {
  my Xerl::XML::Reader $self = $_[0];

  my $parser = XML::SAX::ParserFactory->parser(
    Handler => Xerl::XML::SAXHandler->new()
  );

  $parser->parse_uri($self->get_path());
}

sub parse($) {
  my Xerl::XML::Reader $self = $_[0];

  my $sax_result = $self->sax();

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

    my $flag = 0;

    do {

      # Open XML tag
      if ( $line =~ s#<([^/].+?)( (.*?))? *>##o ) {
        my ( $name, $params ) = ( $1, $3 );
        $flag = 1;

        my $DEBUG = $name =~ /^=/ ? 1 : 0;
        $self->debug($name, $params) if $DEBUG;

        # Ignore XML comments
        next if $name =~ /^!--/o;


        $next = Xerl::XML::Element->new();
        $next->set_name($name);
        $next->set_prev($element);
        $next->set_single($is_single_tag);

        $next->print() if $DEBUG;

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
        $flag = 1;

        #print "XML::<$1>\n";

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
    } while ( $flag == 1 );
  }

  $root->set_name('root');

  # $root->print();
  $self->set_root($root);

  return undef;
}

1;

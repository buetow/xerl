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

package Xerl::Page::Menu;

use strict;
use warnings;

use Xerl::Page::Configure;
use Xerl::Tools::FileIO;
use Xerl::XML::Element;

sub generate($;$) {
    my Xerl::Page::Menu $self        = $_[0];
    my Xerl::Page::Configure $config = $self->get_config();

    my @site    = split /\//, $config->get_site();
    my @compare = @site;
    my $site    = pop @site;

    my ( $content, $siteadd ) = ( 'content/', '' );

    my Xerl::XML::Element $menuelem =
      $self->get_menu( $content, $siteadd, shift @compare );

    $self->push_array($menuelem)
      if $menuelem->first_array()->array_length() > 1;

    for my $s (@site) {
        $content .= "$s.sub/";
        $siteadd .= "$s/";
        $menuelem = $self->get_menu( $content, $siteadd, shift @compare );
        $self->push_array($menuelem)
          if $menuelem->first_array()->array_length() > 1;
    }

    return undef;
}

sub get_menu($$$$) {
    my Xerl::Page::Menu $self        = $_[0];
    my Xerl::Page::Configure $config = $self->get_config();
    my ( $content, $siteadd, $compare ) = ( @_[ 1 ... 2 ], lc $_[3] );
    my $issubsection = $content =~ m{\.sub/$};
    my $pattern = qr/\.(?:xml)|(?:sub)$/;

    my Xerl::Tools::FileIO $io = Xerl::Tools::FileIO->new(
        path     => $config->get_hostpath() . $content,
        basename => 1,
    );
 
    unless ($io->exists()) {
    	Xerl::Main::Global::REDIRECT( $config->get_404() );
	$config->set_shutdown(1);
    }
    
    $io->dslurp();
    my $dir = $io->get_array();

    my ( @prec, @dir );
    map {
        if   (/^\d+\..+\./) { push @prec, $_ }
        else                { push @dir,  $_ }
      }
      grep {
             $_ !~ /^home\.xml$/i
          && $_ !~ /\.feed\.xml$/i
          && $_ !~ /\.hide\.xml$/i
      } @$dir;

    my Xerl::XML::Element $root = Xerl::XML::Element->new();
    my Xerl::XML::Element $menu = Xerl::XML::Element->new();

    $menu->set_name('menu');

    for ( $issubsection ? ( @dir, @prec ) : ( 'home.xml', @dir, @prec ) ) {
        my ($site) = /(.*)$pattern/o;

        $site =~ s#\.$#/home#o;
        $site =~ s/^\d+\.//;

        my $linkname = $site;
        $linkname =~ s/(?:\d+\.)?(.)/\U$1/o;
        $compare .= '/' if $linkname =~ s#(.*/)[^/]+$#$1#;

        my Xerl::XML::Element $item = Xerl::XML::Element->new(
            params => { link => "?site=$siteadd$site" },
            text   => $linkname
        );

        $compare =~ s/^(\d+\.)//;
        $item->set_name(
            lc $linkname eq lc $compare ? 'activemenuitem' : 'menuitem' );

        $item->set_prev($menu);
        $menu->push_array($item);
    }

    $root->push_array($menu);
    $menu->set_prev($root);

    return $root;
}

1;

# Xerl (c) 2005-2011, 2013, 2014 by Paul Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: https://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl::Page::Menu;

use strict;
use warnings;

use v5.14.0;

use Xerl::Base;
use Xerl::Setup::Configure;
use Xerl::Tools::FileIO;
use Xerl::XML::Element;

sub generate {
  my $self   = $_[0];
  my $config = $self->get_config();

  my @site    = split /\//, $config->get_site();
  my @compare = @site;
  my $site    = pop @site;

  my ( $content, $siteadd ) = ( 'content/', '' );

  my $menuelem = $self->get_menu( $content, $siteadd, shift @compare );

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

sub get_menu {
  my $self   = $_[0];
  my $config = $self->get_config();

  my ( $content, $siteadd, $compare ) = ( @_[ 1 ... 2 ], lc $_[3] );
  my $issubsection = $content =~ m{\.sub/$};
  my $pattern = qr/\.(?:xml)|(?:sub)$/;

  my $io = Xerl::Tools::FileIO->new(
    path     => $config->get_hostpath() . $content,
    basename => 1,
  );

  unless ( $io->exists() ) {
    Xerl::Main::Global::REDIRECT( $config->get_404() );
    $config->set_finish_request(1);
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
      && $_ !~ /\.inc\.pl$/i
    } @$dir;

  my $root = Xerl::XML::Element->new();
  my $menu = Xerl::XML::Element->new();

  $menu->set_name('menu');

  for ( $issubsection ? ( @dir, @prec ) : ( 'home.xml', @dir, @prec ) ) {
    my ($site) = /(.*)$pattern/o;

    $site =~ s#\.$#/home#o;
    $site =~ s/^\d+\.//;

    my $linkname = $site;
    $linkname =~ s/(?:\d+\.)?(.)/\U$1/o;
    $compare .= '/' if $linkname =~ s#(.*/)[^/]+$#$1#;

    my $item = Xerl::XML::Element->new(
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

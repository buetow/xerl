# Xerl (c) 2005-2011, 2013-2015 by Paul Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: https://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl::Setup::Configure;

use strict;
use warnings;

use v5.14.0;

use Xerl::Base;
use Xerl::Tools::FileIO;
use Xerl::XML::Element;

sub parse {
  my $self = $_[0];
  my $file = Xerl::Tools::FileIO->new( 'path' => $self->get_config() );

  if ( -1 == $file->fslurp() ) {
    $self->set_finish_request(1);
    return undef;
  }

  my $re = qr/^(.+?) *=(.+?) *\n?$/;

  for ( @{ $file->get_array() } ) {
    next if /^\s*#/;
    s/#.*//;

    $self->setval( $1, $self->eval($2) ) if $_ =~ $re;
  }

  return $self;
}

sub defaults {
  my $self = $_[0];

  $self->set_proto('https') if exists $ENV{HTTPS};

  $self->set_site( $self->get_defaultcontent() )
    unless $self->site_exists();

  $self->set_nsite( $self->get_site() =~ /^(?:\d*\.)?(.*)/ );

  $self->set_template( $self->get_defaulttemplate() )
    unless $self->template_exists();

  $self->set_style( $self->get_defaultstyle() )
    unless $self->style_exists();

  $self->set_proto( $self->get_defaultproto() )
    unless $self->proto_exists();

  $self->set_host( lc $ENV{HTTP_HOST} )
    unless $self->host_exists();

  my ($hostname) = $ENV{HTTP_HOST} =~ /^([^\.]*)\./;

  $self->set_hostname( lc $hostname )
    unless $self->hostname_exists();

  unless ( -d $self->get_hostroot() . $self->get_host() ) {
    my $redirect = $self->get_hostroot() . 'redirect:' . $self->get_host();

    if ( -f $redirect ) {
      my $file = Xerl::Tools::FileIO->new( 'path' => $redirect );
      $file->fslurp();

      my $location = $file->shift();
      Xerl::Main::Global::REDIRECT($location);
      $self->set_finish_request(1);
    }

    my $alias = $self->get_hostroot() . 'alias:' . $self->get_host();

    if ( -f $alias ) {
      my $file = Xerl::Tools::FileIO->new( 'path' => $alias );

      $file->fslurp();
      $self->set_host( $file->shift() );
    }
  }

  $self->set_outputformat( $self->get_defaultoutputformat() )
    unless $self->outputformat_exists();

  if ( $self->format_exists() ) {
    $self->set_outputformat( $self->get_format() );
    $self->set_template( $self->get_format() );
    $self->set_site( $self->get_format() );
    $self->set_nocache(1)
      if $self->get_format() =~ /\.feed$/;
  }

  $self->set_host( $self->getval( $self->get_host() ) )
    if $self->exists( $self->get_host() );

  $self->set_host( $self->getval( $self->get_host() ) )
    if $self->exists( $self->get_host() );

  my $request_subdir = $self->get_request_subdir();
  $self->set_hostpath(
    $self->get_hostroot() . $self->get_host() . $request_subdir . "/" );

  $self->set_defaulthostpath(
    $self->get_hostroot() . $self->get_defaulthost() . '/' );

  $self->set_cachepath(
    $self->get_cacheroot() . $self->get_host() . $request_subdir . '/' );

  $self->set_htdocspath( $self->get_hostpath() . 'htdocs/' );

  $self->set_templatespath( $self->get_hostpath() . 'templates/' );

  $self->set_contentpath( $self->get_hostpath() . 'content/' );

  $self->set_is_ipv6( $ENV{REMOTE_ADDR} =~ /:/ ? 1 : 0 );

  return undef;
}

sub eval {
  my $self = $_[0];
  my $val  = $_[1];

  $val =~ s/^!(.+)/`$1`/eo;

  return $val;
}

sub insertxmlvars {
  my $self    = $_[0];
  my $element = $_[1];

  $element = $element->starttag('variables');

  return $self
    unless defined $element
      or $element->get_array() eq 'ARRAY';

  my $text;
  for ( @{ $element->get_array() } ) {
    $text = $_->get_text();
    chomp $text;

    $text =~ s/%%(.*?)%%/$self->getval($1)/eg;
    $self->setval( $_->get_name(), $text );
  }

  return $self;
}

1;


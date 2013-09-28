# Xerl (c) 2005-2011, 2013 Dipl.-Inform. (FH) Paul C. Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl::Page::Document;

use strict;
use warnings;

use v5.14.0;

use Xerl::Base;
use Xerl::Main::Global;
use Xerl::Setup::Configure;
use Xerl::Tools::FileIO;

sub parse($) {
  my Xerl::Page::Document $self    = $_[0];
  my Xerl::Setup::Configure $config = $self->get_config();

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

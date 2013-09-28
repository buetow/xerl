# Xerl (c) 2005-2011, 2013 Dipl.-Inform. (FH) Paul C. Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl::Tools::FileIO;

use strict;
use warnings;

use Xerl::Base;
use Xerl::Main::Global;

sub dslurp($;$) {
  my Xerl::Tools::FileIO $self = $_[0];

  my $path = $self->get_path();

  $path .= '/' unless $path =~ /\/$/;
  opendir my $dir, $path or Xerl::Main::Global::ERROR( $!, $path, caller() );

  my @dir = sort
    map  { $path . $_ }
    grep { /^[^\.]/o } readdir($dir);

  @dir = map { s#.*/([^/]+\..+)$#$1#o; $_ } @dir
    if $self->basename_exists();

  closedir $dir;
  $self->set_array( \@dir );

  return undef;
}

sub fslurp($) {
  my Xerl::Tools::FileIO $self = $_[0];
  my $path = _SECUREPATH( $self->get_path() );

  unless ( -f $path ) {
    Xerl::Main::Global::HTTP( 404, "Not found: $path" );
    return -1;
  }

  open my $file, $path or Xerl::Main::Global::ERROR( $!, $path, caller() );
  flock $file, 2;

  my @slurp = <$file>;

  flock $file, 3;
  close $file;

  $self->set_array( \@slurp );

  return 0;
}

sub exists($) {
  my Xerl::Tools::FileIO $self = $_[0];
  my $path = _SECUREPATH( $self->get_path() );

  return -e $path;
}

sub fwrite($) {
  my Xerl::Tools::FileIO $self = $_[0];
  $self->_fwrite(0);

  return undef;
}

sub fwriteappend($) {
  my Xerl::Tools::FileIO $self = $_[0];

  $self->_fwrite(1);

  return undef;
}

sub _fwrite($;$) {
  my Xerl::Tools::FileIO $self = $_[0];
  my $append = $_[1];

  my ( $path, $filename ) =
    ( _SECUREPATH( $self->get_path() ), _SECUREPATH( $self->get_filename() ) );

  my $path_ = '';
  for ( split /\//, $path ) {
    $path_ .= $_ . '/';
    mkdir $path_
      or Xerl::Main::Global::ERROR( $!, $path_, caller() )
      unless -d $path_;
  }

  my $f;
  if ( $append == 0 ) {
    open $f, ">$path$filename"
      or Xerl::Main::Global::ERROR( $!, $path . $filename, caller() );

  }
  else {
    open $f, ">>$path$filename"
      or Xerl::Main::Global::ERROR( $!, $path . $filename, caller() );
  }

  flock $f, 2;
  print $f @{ $self->get_array() };
  flock $f, 3;
  close $f;

  return undef;
}

sub print($) {
  my Xerl::Tools::FileIO $self = $_[0];

  print @{ $self->get_array() };

  return undef;
}

sub reverse_array($) {
  my Xerl::Tools::FileIO $self = $_[0];

  my @array = reverse @{ $self->get_array() };
  $self->set_array( \@array );

  return undef;
}

sub merge($$) {
  my Xerl::Tools::FileIO( $self, $other ) = @_;

  my @merged = ( @{ $self->get_array() }, @{ $other->get_array() } );
  my Xerl::Tools::FileIO $fio = Xerl::Tools::FileIO->new();

  $fio->set_array( \@merged );
  return $fio;
}

sub shift($) {
  my Xerl::Tools::FileIO $self = $_[0];
  chomp( my $shift = shift @{ $self->get_array() } );

  return $shift;
}

sub pop($) {
  my Xerl::Tools::FileIO $self = $_[0];
  chomp( my $pop = pop @{ $self->get_array() } );

  return $pop;
}

use overload '+' => \&merge;

sub _SECUREPATH($) {
  my $path = $_[0];

  $path =~ s/\.\.+\/?//g;

  return $path;
}

1;

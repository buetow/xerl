# Xerl (c) 2005-2011, 2013-2015 by Paul Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl::Page::Rules;

use strict;
use warnings;

use v5.14.0;

use Xerl::Base;
use Xerl::Setup::Configure;
use Xerl::XML::Element;

sub parse {
  my $self    = $_[0];
  my $element = $_[1];
  my $config  = $self->get_config();

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

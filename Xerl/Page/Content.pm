# Xerl (c) 2005-2011, 2013 Dipl.-Inform. (FH) Paul C. Buetow
#
# 	E-Mail: xerl@dev.buetow.org 	WWW: http://xerl.buetow.org
#
# This is free software, you may use it and distribute it under the same
# terms as Perl itself.

package Xerl::Page::Content;

use strict;
use warnings;

use v5.14.0;

use Xerl::Base;
use Xerl::Page::Rules;
use Xerl::Setup::Configure;
use Xerl::XML::Element;
use Xerl::XML::Reader;

sub parse($) {
  my Xerl::Page::Content $self     = $_[0];
  my Xerl::Setup::Configure $config = $self->get_config();

  my Xerl::XML::Reader $xmlcontent = Xerl::XML::Reader->new(
    path   => $config->get_templatepath(),
    config => $config
  );

  if ( -1 == $xmlcontent->open() ) {
    $config->set_finish_request(1);
    return undef;
  }

  $xmlcontent->parse();

  my Xerl::Page::Rules $rules = Xerl::Page::Rules->new( config => $config );
  $rules->parse( $config->get_xmlconfigrootobj() )
    unless $config->exists('noparse');

  $config->insertxmlvars( $config->get_xmlconfigrootobj() );
  $self->insertrules( $rules, $xmlcontent->get_root() );

  return undef;
}

sub insertrules($$$$) {
  my Xerl::Page::Content $self   = $_[0];
  my Xerl::Page::Rules $rules    = $_[1];
  my Xerl::XML::Element $element = $_[2];

  # Start inserting rules at <content>
  $element = $element->starttag('content');

  # If there is no <content>-tag, dont use a rule!
  return unless defined $element;

  my @content;
  my $params = $element->get_params();

  unshift @content, "Content-Type: $params->{type}\n\n"
    if ref $params eq 'HASH' and exists $params->{type};

  push @content, $self->_insertrules( $rules, $element );
  $self->set_content( \@content );

  return undef;
}

sub _insertrules($$$) {
  my Xerl::Page::Content $self     = $_[0];
  my Xerl::Page::Rules $rules      = $_[1];
  my Xerl::XML::Element $element   = $_[2];
  my Xerl::Setup::Configure $config = $self->get_config();
  my $nonewlines                   = 0;

  # Don't interate through the XML childs if we have a leaf node.
  return () unless ref $element->get_array() eq 'ARRAY';
  my ( $name, $rule, @content, $text, $params );

  for my $succ ( @{ $element->get_array() } ) {
    $name   = $succ->get_name();
    $text   = $succ->get_text();
    $params = $succ->get_params();

    # Remove leading and ending whitespaces, also ending newlines.
    $text =~ s/^ *(.*)( |\n)*$/$1/g;
    unless ( ref( $rule = $rules->getval($name) ) eq 'ARRAY' ) {
      if ( lc $name eq 'noop' ) {
        if ( ref $succ->get_array() eq 'ARRAY' ) {
          push @content, $self->_insertrules( $rules, $succ );

        }
        else {
          push @content, "$text\n";
        }

      }
      elsif ( lc $name eq 'tag' ) {
        push @content, "<$text>\n";

      }
      elsif ( lc $name eq 'perl' ) {
        push @content, '<perl>', $text, '</perl>';

      }
      elsif ( lc $name eq 'navigation' ) {
        my $menus = $config->get_menuobj()->get_array();

        if ( ref $menus eq 'ARRAY' ) {
          push @content, $self->_insertrules( $rules, $_ ) for @$menus;
        }

      }
      else {

        # No rule available, use the tag unmodified!
        $name =~ s/^=//o;    # Remove the leading =
        if ( $succ->get_single() ) {
          push @content, "<$name" . ( $succ->params_str() || '' ) . " />\n"

        }
        else {
          push @content,
            "<$name" . ( $succ->params_str() || '' ) . '>',
            $self->_insertrules( $rules, $succ ), $text, "</$name>\n";
        }
      }

    }
    else {

      # Get a local copy of lrule, because orule may be modified.
      # And then insert special vars if required:
      #  @@text@@ => Text content of the current tag.

      my $ruleparams = $rule->[2];
      $nonewlines = 1 if exists $ruleparams->{nonewlines};

      my ( $orule, $crule ) = ( $rule->[0], $rule->[1] );

      $self->_insert_special_vars( $rules, $succ, \$orule );
      $self->_insert_special_vars( $rules, $succ, \$crule );
      chomp $orule;

      # Parse for known tag params.
      if ( ref $params eq 'HASH' ) {
        Xerl::Page::Templates::PARSELINE( $config, '%%', \$text );

        # <tag basename='yes'>path/to/file.bla</tag> => <tag>file.bla</tag>
        $text =~ s#.*/(.*)$#$1# if lc $params->{basename} eq 'yes';

        # <tag cut='?'>foo.bar.tld?options</tag> => <tag>?options</tag>
        if ( exists $params->{cut} ) {
          my $cut = quotemeta $params->{cut};
          $text =~ s/.*$cut(.*)$/$1/o;
        }

        $text .= $params->{addback}
          if exists $params->{addback};
        $text = $params->{addfront} . $text
          if exists $params->{addfront};
      }

      my $oadd =
        exists $ruleparams->{addfront}
        ? '<' . $ruleparams->{addfront}
        : '';

      my $cadd =
        exists $ruleparams->{addback} ? $ruleparams->{addback} . '>' : '';

      push @content, $orule, $oadd, $self->_insertrules( $rules, $succ ),
        $text, $cadd, $crule;
    }
  }

  return $nonewlines ? map { s/\n/ /go; $_ } @content : @content;
}

sub _insert_special_vars($$$$) {
  my Xerl::Page::Content $self     = $_[0];
  my Xerl::Page::Rules $rules      = $_[1];
  my Xerl::XML::Element $element   = $_[2];
  my Xerl::Setup::Configure $config = $self->get_config();
  my $rtext                        = $_[3];

  $$rtext =~ s/@\@text\@\@/$_=$element->get_text();chomp;$_/geo;
  $$rtext =~ s/@\@ln\@\@//go;

  if ( $$rtext =~ /@\@(.*?)\@\@/ ) {
    my $params = $element->get_params();
    return unless ref $params eq 'HASH';
    $$rtext =~ s/@\@(.*?)\@\@/$params->{$1}||''/geo;
  }

  return undef;
}

1;

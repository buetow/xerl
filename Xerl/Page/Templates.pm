# Xerl (c) 2005-2011, Dipl.-Inform. (FH) Paul C. Buetow
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

package Xerl::Page::Templates;

use strict;
use warnings;

use Time::HiRes 'tv_interval';
use Digest::MD5;

use Xerl::Base;
use Xerl::Page::Configure;
use Xerl::Page::Content;
use Xerl::Page::Menu;
use Xerl::Tools::FileIO;

use constant RECURSIVE => 1;

sub parse($) {
    my Xerl::Page::Templates $self   = $_[0];
    my Xerl::Page::Configure $config = $self->get_config();

    my $site = $config->get_site();

    my $subpath = $site;
    if ( $site =~ s#^.*/(.*)$#$1#o ) {
        $subpath =~ s#/[^/]+$#/#;
        $subpath =~ s#/#.sub/#go;

    }
    else {
        $subpath = '';
    }

    my $cachefile =
        $config->get_template() . ';'
      . $config->get_outputformat() . ';'
      . $site
      . ( $config->noparse_exists() ? '.noparse' : '' )
      . '.cache';

    my $cachepath = $config->get_cachepath() . $subpath;

    if ( -f $cachepath . $cachefile
        && ( $config->usecache_exists() or not $config->nocache_exists() ) )
    {

        my Xerl::Tools::FileIO $io =
          Xerl::Tools::FileIO->new( path => $cachepath . $cachefile );

        if ( -1 == $io->fslurp() ) {
            $config->set_shutdown(1);
            return undef;
        }

        $self->set_array( $io->get_array() );

    }
    else {

        my $xmlconfigpath = $config->get_hostpath() . 'config.xml';

        $xmlconfigpath = $config->get_defaulthostpath() . 'config.xml'
          unless -f $xmlconfigpath;

        my Xerl::XML::Reader $xmlconfigreader =
          Xerl::XML::Reader->new( path => $xmlconfigpath, config => $config );

        if ( -1 == $xmlconfigreader->open() ) {
            $config->set_shutdown(1);
            return undef;
        }
        $xmlconfigreader->parse();
        $config->set_xmlconfigrootobj( $xmlconfigreader->get_root() );

        my Xerl::Page::Menu $menu = Xerl::Page::Menu->new( config => $config );

        $menu->generate();
        $config->set_menuobj($menu);

        if ( $site =~ /^(\d+)\./ ) {
            $config->set_templatepath(
                $config->get_hostpath() . "content/$subpath$site.xml" );
        }
        elsif ( -f $config->get_hostpath() . "content/$subpath$site.xml" ) {
            $config->set_templatepath(
                $config->get_hostpath() . "content/$subpath$site.xml" );
        }

        # Hidden files
        elsif ( -f $config->get_hostpath() . "content/$subpath.$site.xml" ) {
            $config->set_templatepath(
                $config->get_hostpath() . "content/$subpath.$site.xml" );
        }
        else {
            my $glob = $config->get_hostpath() . "content/$subpath*.$site.xml";
            eval "(\$glob) = sort <$glob>;";
            $config->set_templatepath($glob);
        }

        my Xerl::Page::Content $bodycontent =
          Xerl::Page::Content->new( config => $config );

        $bodycontent->parse();

        my $templatepath =
            $config->get_hostpath()
          . "templates/"
          . $config->get_template() . '.xml';

        $templatepath =
            $config->get_defaulthostpath()
          . "templates/"
          . $config->get_template() . '.xml'
          unless -f $templatepath;

        $config->set_templatepath($templatepath);

        my Xerl::Page::Content $templatecontent =
          Xerl::Page::Content->new( config => $config );

        $templatecontent->parse();

        $self->set_array( $templatecontent->get_content() );
        $config->set_content( $bodycontent->get_content() );
        $self->parsetemplate( '%%', RECURSIVE );

        my Xerl::Tools::FileIO $io = Xerl::Tools::FileIO->new(
            path     => $cachepath,
            filename => $cachefile,
            array    => $self->get_array(),
        );

        $io->fwrite();
    }

    unless ( $config->nolog_exists() ) {
        my @time = localtime;
        my $ctx  = Digest::MD5->new();
        $ctx->add( $ENV{REMOTE_ADDR} );

        my Xerl::Tools::FileIO $stats = Xerl::Tools::FileIO->new(
            path     => $config->get_statsroot(),
            filename => sprintf(
                "\%02d%02d%02d", $time[5] - 100, $time[4] + 1, $time[3]
              )
              . '.log',
            array => [
                time() . ' '
                  . $ctx->hexdigest() . ' '

                  #. $ENV{REMOTE_ADDR} . ' '
                  . $config->get_host()
                  . $config->get_request_subdir() . ' '
                  . $config->get_site() . ' '
                  . $ENV{HTTP_USER_AGENT} . "\n"
            ],
        );

        $stats->fwriteappend();
    }

    $self->parsetemplate('$$');    # Parsing dynamic vars.
    return undef;
}

sub parsetemplate($$;$) {
    my Xerl::Page::Templates $self   = $_[0];
    my Xerl::Page::Configure $config = $self->get_config();
    my $deepnesslevel = $_[2] || 0;

    return $self if $deepnesslevel == 100;

    my ( $sep, $foundflag ) = quotemeta $_[1];

    PARSELINE( $config, $sep, \$_, \$foundflag ) for @{ $self->get_array() };

    return $self->parsetemplate( $_[1], $deepnesslevel + 1 )
      if defined $deepnesslevel > 0 and $foundflag;

    return undef;
}

# Static sub
sub PARSELINE($$$;$) {
    my Xerl::Page::Configure $config = $_[0];
    my ( $sep, $line, $foundflag ) = @_[ 1 .. 3 ];

    $$line =~ s/$sep(!)?(.+?)$sep/
     defined $1 ? `$2` :
       (ref $config->getval($2) eq 'ARRAY') 
  	  ? join '', @{$config->getval($2)} :
	    $config->getval($2)/eg and $$foundflag = 1;

    return undef;
}

sub print($;$) {
    my Xerl::Page::Templates $self   = $_[0];
    my Xerl::Page::Configure $config = $self->get_config();

    my ( $code, $flag ) = ( '', 0 );
    my $time  = $_[1];
    my $hflag = 1;

    for my $line ( @{ $self->get_array() } ) {
        if ( $hflag == 1 && $config->exists('noparse') ) {
            $line =~ s#^Content-Type.*#Content-Type: text/plain#i;
            $hflag = 0;
        }
        $line =~ s/  +/ /g;
        redo if !$flag and $line =~ s/<perl>((?:.|\n)*?)<\/perl>/eval $1/ego;

        if ( !$flag and $line =~ s/<perl>(.*)$//o ) {
            $code .= $1;
            $flag = 1;

        }
        elsif ( $line =~ s/^(.*?)<\/perl>/eval $code.$1/eo ) {
            ( $code, $flag ) = ( '', 0 );
            redo;

        }
        elsif ($flag) {
            $line =~ s/^(.*\n)$//o;
            $code .= $1;
            next;
        }

        my $time = defined $time ? sprintf '%1.4f', tv_interval($time) : '';

        $line =~ s/!!TIME!!/$time/ge;
        $line =~ s/!!LT!!/</g;
        $line =~ s/!!GT!!/>/g;
        $line =~ s#!!URL\((.+?)\)!!#<a href="$1">$1</a>#g;
        print $line;
    }

    return undef;
}

1;

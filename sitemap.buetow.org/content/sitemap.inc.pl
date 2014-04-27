my $hostroot = $config->get_hostroot();

sub getf ($) {
  open my $f, $_[0] or die "$!: $_[0]\n";
  my @slurp = <$f>;
  close $f; 
  @slurp;
}

sub nl () { "<br />\n" }

sub list (*) {
  my $tag = shift;
  my @found = sort `find $hostroot -name $tag`;
  my $ret = '';


  for my $found (@found) {
    $found =~ /.*hosts.(.*?).$tag/;
    my $host = $1;

    my @content = getf $found;

    $ret .= "<b><a href=http://$host>$host</a></b>" . nl;;

    if (@content) {
      $ret .= join " ", @content;
      $ret .= nl;
    }
    $ret .= nl; 
  }

  $ret;
}

list SITEMAP;

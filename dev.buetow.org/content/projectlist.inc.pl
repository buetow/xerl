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

    $ret .= "<b><a href=https://$host>$host</a></b>" . nl;
    if (@content) {
      $ret .= join " ", @content;
      $ret .= nl;
    }
    $ret .= nl; 
  }

  $ret;
}

my $ret = list PROJECT;

$ret .= "<b><i>Older projects (not active at the moment):</i></b>" . nl x 2;
$ret .= list OLDPROJECT;
$ret .= "<b><i>Obsolete projects (no work will be done anymore and the software may be broken):</i></b>" . nl x 2;
$ret .= list OBSOLETEPROJECT;

return $ret;

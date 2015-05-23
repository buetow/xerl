my $hostroot = $config->get_hostroot();

sub space () { "&nbsp;" x 10 }
sub nl () { "<br />\n" }

sub list (*) {
  my $tag = shift;
  my @homepages = sort `find $hostroot -name $tag`;
  my @ret = ();

  for my $homepage (sort @homepages) {
    my ($host) = $homepage =~ /.*hosts.(.*?).$tag/;
    push @ret, "<b><a href='http://$host'>$host</a></b>", nl;

    my $sitepath = "$hostroot/$host";

    my @pages = sort `find $sitepath -name \*.xml`;
    for my $page (sort @pages) {
      my ($site) = $page =~ m#$host/content/(.*)\.xml$#;
      $site =~ s#\.sub/#/#g;
      $site =~ s#\d\d\.##g;
      next if $site eq 'home';
      my $sitelink = "http://$host?site=$site";
      push @ret, space, "<a href='$sitelink'>$site</a>", nl;
    }

    push @ret, nl;
  }

  join '', @ret;
}

list SITEMAP;

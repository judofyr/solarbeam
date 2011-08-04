SolarBeam
=========

Super effective Solr client in Perl that uses Mojolicious' event loop.

## Synopsis

```perl
use SolarBeam;

my $sb = SolarBeam->new(url => 'http://localhost:8983/solr/');

$sb->search('Hello World', sub {
  my $res = pop;
  print $res->ok;
  print $res->numFound;
  print $res->docs->[0]->{name};
});

$sb->search({author => 'Magnus Holm'}, sub {
  my $res = pop;
  # …
});

Mojo::IOLoop->start;
```

## Complex queries

If you need more complex queries (and *don't* want to manually escape
input) you can give `search()` a HASHREF. At the moment it uses
[WebService::Solr::Query][solr-query] to build the query, but this might
change in the future.

[solr-query]: http://search.cpan.org/~bricas/WebService-Solr-0.15/lib/WebService/Solr/Query.pm


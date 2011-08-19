use strict;
use warnings;

use Test::More tests => 13;

sub is_query {
  my $url = shift;
  if (scalar(@_) % 2 == 1) {
    is($url->path, shift);
  }
  my %query = @_;
  is_deeply($url->query->to_hash, \%query);
}

use_ok 'SolarBeam';

my $sb = SolarBeam->new(url => 'http://localhost/');
is($sb->url, 'http://localhost/');

is($sb->escape('hel*o "world'), 'hel*o "world');
is($sb->escape(\'hel*o "world'), 'hel\\*o \\"world');

is($sb->build_query('hello'), 'hello');
is($sb->build_query(['%hello = %world', hello => '*', world => \'*']), '* = \\*');
is($sb->build_query({hello => 'world'}), '(hello:(world))');

is_query(
  $sb->build_url(),
  '/select',
  wt => 'json'
);

is_query(
  $sb->build_url({ page => 5, rows => 10 }),
  '/select',
  rows => 10,
  start => 40,
  wt => 'json'
);

is_query(
  $sb->build_url({ fq => 'hello*' }),
  '/select',
  fq => 'hello*',
  wt => 'json'
);

is_query(
  $sb->build_url({ fq => [
        '(foo)',
        {bar => 1},
        ['qux:%qux', qux => \'cool*']
    ]}),

  '/select',
  wt => 'json',
  fq => ['(foo)', '(bar:(1))', 'qux:cool\*']
);

is_query(
  $sb->build_url({ facet => {
        field => 'identifier.owner',
        mincount => 1
      }}),

  '/select',
  wt => 'json',
  facet => 'true',
  'facet.field' => 'identifier.owner',
  'facet.mincount' => 1
);


is_query(
  $sb->build_url({ facet => {
        range => {
          -value => 'year', gap => 100, start => 0, end => 2000
        },
        mincount => 1
      }}),

  '/select',
  wt => 'json',
  facet => 'true',
  'facet.range' => 'year',
  'facet.range.gap' => 100,
  'facet.range.start' => 0,
  'facet.range.end' => 2000,
  'facet.mincount' => 1
);

is_query(
  $sb->build_url({ -endpoint => 'terms', terms => {
        fl => 'artifact.name'
      }}),
  '/terms',
  wt => 'json',
  terms => 'true',
  'terms.fl' => 'artifact.name'
);


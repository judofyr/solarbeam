use strict;
use warnings;

use Test::More 'no_plan';

use Mojo::JSON;
use File::Basename;

sub fixture {
  my $name = shift;
  my $file = dirname(__FILE__).'/fixtures/'.$name.'.json';
  open(FILE, $file) or die 'Could not open '.$file;
  my $content = <FILE>;
  close(FILE);
  Mojo::JSON->new->decode($content);
}

use_ok 'SolarBeam::Response';

my $res = SolarBeam::Response->new(fixture('simple'));
ok($res->ok);
is($res->numFound, 2462);
is($res->pager->total_entries, 2462);
ok($res->docs);
is(scalar @{$res->docs}, 10);

$res = SolarBeam::Response->new(fixture('facets'));
ok($res->ok);
ok($res->facet_fields);
is(scalar @{$res->facet_fields->{'identifier.owner'}}, 168);

$res = SolarBeam::Response->new(fixture('terms'));
ok($res->ok);
ok($res->terms);
is(scalar keys %{$res->terms->{'artifact.name'}}, 10);

$res = SolarBeam::Response->new(fixture('fail'));
ok(!$res->ok);

$res = SolarBeam::Response->new(fixture('unknown'));
ok($res->ok);


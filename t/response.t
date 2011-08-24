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
is(scalar @{$res->facet_fields->{'identifier.owner'}}, 84);
is($res->facet_fields->{'identifier.owner'}->[0]->{value}, 'NF');
is($res->facet_fields->{'identifier.owner'}->[0]->{count}, 358262);


$res = SolarBeam::Response->new(fixture('ranges'));
ok($res->ok);
ok($res->facet_ranges);
my $year = $res->facet_ranges->{'artifact.ingress.production.fromYear'};
is($year->{start}, -4000);
is($year->{end}, 3000);
is(scalar @{$year->{counts}}, 26);
is($year->{counts}->[0]->{value}, 1750);
is($year->{counts}->[0]->{count}, 20);

$res = SolarBeam::Response->new(fixture('terms'));
ok($res->ok);
ok($res->terms);
is(scalar @{$res->terms->{'artifact.name'}}, 10);
is($res->terms->{'artifact.name'}->[0]->{value}, 'oslo');
is($res->terms->{'artifact.name'}->[0]->{count}, 2535);

$res = SolarBeam::Response->new(fixture('fail'));
ok(!$res->ok);

$res = SolarBeam::Response->new(fixture('unknown'));
ok($res->ok);


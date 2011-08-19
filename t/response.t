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
is($res->numFound, 2462);
ok($res->docs);
is(scalar @{$res->docs}, 10);

my $res = SolarBeam::Response->new(fixture('facets'));
ok($res->facet_fields);
is(scalar @{$res->facet_fields->{'identifier.owner'}}, 168);



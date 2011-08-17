use strict;
use warnings;

use Test::More tests => 8;

use_ok 'SolarBeam';

my $sb = SolarBeam->new(url => 'http://localhost/');
is($sb->url, 'http://localhost/');

is($sb->escape('hel*o "world'), 'hel*o "world');
is($sb->escape(\'hel*o "world'), 'hel\\*o \\"world');

is($sb->build_query('hello'), 'hello');
is($sb->build_query(['%hello = %world', hello => '*', world => \'*']), '* = \\*');
is($sb->build_query({hello => 'world'}), '(hello:(world))');

my $opt = { page => 4, rows => 50 };
$sb->handle_page($opt->{page}, $opt);
is($opt->{start}, 150);


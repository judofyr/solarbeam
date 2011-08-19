use strict;
use warnings;

use Test::More 'no_plan';
use_ok 'SolarBeam';

my $sb = SolarBeam->new(url => 'http://localhost/');
my $mock = UserAgentMock->new;
$sb->user_agent($mock);

$mock->expect("/select", wt => 'json', q => 'hello');
$sb->search("hello", sub {});


$mock->expect("/terms",
  wt => 'json',
  terms => 'true',
  'terms.fl' => 'artifact.name',
  'terms.regex' => 'ost.*',
  'terms.regex.flag' => 'case_insensitiv'
);

$sb->autocomplete('ost', fl => 'artifact.name', sub {});

package UserAgentMock;
use Test::More;

sub new {
  bless {}, 'UserAgentMock';
}

sub expect {
  my $self = shift;
  $self->{expect} = \@_;
}

sub get {
  my ($self, $url) = @_;
  my $expect = delete $self->{expect};
  ok($expect);
  my ($path, %query) = @{$expect};
  is($url->path, $path);
  is_deeply($url->query->to_hash, \%query);
}


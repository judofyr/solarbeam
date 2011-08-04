package SolarBeam;

use Mojo::Base -base;
use Mojo::UserAgent;
use Mojo::URL;
use SolarBeam::Response;
use WebService::Solr::Query;

has 'url';
has 'mojo_url' => sub { Mojo::URL->new(shift->url) };
has 'user_agent' => sub { Mojo::UserAgent->new };

sub search {
  my $callback = pop;
  my ($self, $query, %options) = @_;
  $query = $self->build_query($query);

  my $url = $self->mojo_url->clone;
  $url->path('select');
  $url->query(q => $query, wt => 'json');
  $url->query(\%options);

  $self->user_agent->get($url, sub {
    my $res = SolarBeam::Response->new(pop->res->json);
    $callback->(shift, $res);
  });
}

sub build_query {
  my ($self, $query) = @_;

  if (ref $query) {
    WebService::Solr::Query->new($query);
  } else {
    $query;
  }
}

"It's super effective!";


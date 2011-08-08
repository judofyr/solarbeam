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

  my $page = $options{page};
  if ($page) {
    die "You must provide both page and rows" unless $options{rows};
    $options{start} = ($page - 1) * $options{rows};
    delete $options{page};
  }

  $url->query(\%options);

  $self->user_agent->get($url, sub {
    my $res = SolarBeam::Response->new(pop->res->json);

    if ($page && $res->ok) {
      $res->page->current_page($page);
      $res->page->entries_per_page($options{rows});
    }

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


package SolarBeam;

use Mojo::Base -base;
use Mojo::UserAgent;
use Mojo::URL;
use SolarBeam::Response;
use SolarBeam::Query;

has 'url';
has 'mojo_url' => sub { Mojo::URL->new(shift->url) };
has 'user_agent' => sub { Mojo::UserAgent->new };

my $escape_all   = quotemeta( '+-&|!(){}[]^"~*?:\\' );
my $escape_wilds = quotemeta( '+-&|!(){}[]^"~:\\' );

sub search {
  my $callback = pop;
  my ($self, $query, %options) = @_;
  my $options = \%options;
  $query = $self->build_query($query);

  my $url = $self->mojo_url->clone;
  $url->path('select');
  $url->query(q => $query, wt => 'json');

  my $page = $options->{page};
  $self->handle_page($options->{page}, $options) if $page;
  $self->handle_fq($options->{fq}, $options) if $options->{fq};

  $url->query($options);

  $self->user_agent->get($url, sub {
    my $res = SolarBeam::Response->new(pop->res->json);

    if ($page && $res->ok) {
      $res->pager->current_page($page);
      $res->pager->entries_per_page($options->{rows});
    }

    $callback->(shift, $res);
  });
}

sub handle_page {
  my ($self, $page, $options) = @_;
  die "You must provide both page and rows" unless $options->{rows};
  $options->{start} = ($page - 1) * $options->{rows};
  delete $options->{page};
}

sub handle_fq {
  my ($self, $fq, $options) = @_;

  if (ref($fq) eq 'ARRAY') {
    my @queries = map { $self->build_query($_) } @{$fq};
    $options->{fq} = \@queries;
  } else {
    $options->{fq} = $self->build_query($fq);
  }
}

sub build_query {
  my ($self, $query) = @_;

  my $type = ref($query);
  if ($type eq 'HASH') {
    SolarBeam::Query->new($query);
  } elsif ($type eq 'ARRAY') {
    my ($raw, %params) = @{$query};
    $raw =~ s|%([a-z]+)|$self->escape($params{$1})|ge;
    $raw;
  } else {
    $query;
  }
}

sub escape {
  my $text = pop;
  my $chars;

  if (ref($text)) {
    $text = ${$text};
    $chars = $escape_all;
  } else {
    $chars = $escape_wilds;
  }

  $text =~ s{([$chars])}{\\$1}g;
  return $text;
}

"It's super effective!";


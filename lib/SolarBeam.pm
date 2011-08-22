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
my $escape_wilds = quotemeta( '+-&|!(){}[]^~:\\' );

sub search {
  my $callback = pop;
  my ($self, $query, %options) = @_;
  my $options = \%options;
  my $page = $options->{page};
  $options->{-query} = $query;

  my $url = $self->build_url($options);

  $self->user_agent->get($url, sub {
    my $res = SolarBeam::Response->new(pop->res->json);

    if ($page && $res->ok) {
      $res->pager->current_page($page);
      $res->pager->entries_per_page($options->{rows});
    }

    $callback->(shift, $res);
  });
}

sub autocomplete {
  my $callback = pop;
  my ($self, $prefix, %options) = @_;
  $options{'regex.flag'} = 'case_insensitive';
  $options{'regex'} = quotemeta($prefix) . '.*';
  my $options = { terms => \%options, -endpoint => 'terms' };

  my $url = $self->build_url($options);

  $self->user_agent->get($url, sub {
    my $res = SolarBeam::Response->new(pop->res->json);
    $callback->(shift, $res);
  });
}

sub build_url {
  my ($self, $options) = @_;

  my $endpoint = delete $options->{-endpoint};
  my $query = delete $options->{-query};
  my $url = $self->mojo_url->clone;

  $url->path($endpoint || 'select');
  $url->query(q => $self->build_query($query)) if $query;
  $url->query({wt => 'json'});

  if ($options->{page}) {
    $self->handle_page($options->{page}, $options);
  }

  if ($options->{fq}) {
    $self->handle_fq($options->{fq}, $options);
  }

  if ($options->{facet}) {
    $self->handle_facet($options->{facet}, $options);
  }

  if ($options->{terms}) {
    $self->handle_nested_hash('terms', $options->{terms}, $options);
  }

  $url->query($options);

  return $url;
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

sub handle_facet {
  my ($self, $facet, $options) = @_;
  $self->handle_nested_hash('facet', $facet, $options);
}

sub handle_nested_hash {
  my ($self, $prefix, $content, $options) = @_;
  my $type = ref $content;

  if ($type eq 'HASH') {
    $content->{-value} or $content->{-value} = 'true';

    for my $key (keys %{$content}) {
      my $name = $prefix;
      $name .= '.'. $key if $key ne '-value';
      $self->handle_nested_hash($name, $content->{$key}, $options);
    }
  } else {
    $options->{$prefix} = $content;
  }
}

sub build_query {
  my ($self, $query) = @_;

  my $type = ref($query);
  if ($type eq 'HASH') {
    $self->build_hash(%{$query});
  } elsif ($type eq 'ARRAY') {
    my ($raw, %params) = @{$query};
    $raw =~ s|%([a-z]+)|$self->escape($params{$1})|ge;
    $raw;
  } else {
    $query;
  }
}

sub build_hash {
  my ($self, %fields) = @_;

  '('.
    join(' AND ',
    map { $_ . ':(' . $self->escape($fields{$_}). ')' } keys %fields).
  ')';
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


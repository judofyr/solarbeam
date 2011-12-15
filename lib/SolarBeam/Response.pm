package SolarBeam::Response;

use Mojo::Base -base;
use Data::Page;

has 'status';
has 'error' => 'Unknown error';
has 'QTime';
has 'params';

has 'numFound';
has 'start';
has 'docs' => sub { [] };

has 'facet_queries';
has 'facet_fields';
has 'facet_dates';
has 'facet_ranges';

has 'terms';

has 'pager' => sub { Data::Page->new };

sub new {
  my ($class, $msg) = @_;
  my $self = $class->SUPER::new;
  my $data = $msg->json;

  my $header = $data->{responseHeader};
  my $res = $data->{response};
  my $facets = $data->{facet_counts};
  my $terms = $data->{terms};
  my $field;

  if (!$header) {
    $self->status(1);
    my $dom = $msg->dom;
    my $title = $dom->at('title') if $dom;

    if ($title) {
      $self->error($title->text);
    } else {
      $self->error($msg->code .': '. $msg->body);
    }
    return $self;
  }

  for $field (keys %{$header}) {
    $self->$field($header->{$field}) if $self->can($field);
  }

  for $field (keys %{$res}) {
    $self->$field($res->{$field}) if $self->can($field);
  }

  for $field (keys %{$facets}) {
    $self->$field($facets->{$field}) if $self->can($field);
  }

  my $ff = $self->facet_fields;
  if ($ff) {
    for $field (keys %$ff) {
      $ff->{$field} = $self->build_count_list($ff->{$field});
    }
  }

  if ($self->facet_ranges) {
    for $field (keys %{$self->facet_ranges}) {
      my $range = $self->facet_ranges->{$field};
      $range->{counts} = $self->build_count_list($range->{counts});
    }
  }

  if ($terms) {
    my $sane_terms = {};
    for $field (keys %{$terms}) {
      $sane_terms->{$field} = $self->build_count_list($terms->{$field});
    }
    $self->terms($sane_terms);
  }
  
  if ($self->ok && $res) {
    $self->pager->total_entries($self->numFound);
  }

  $self;
}

sub ok {
  my $self = shift;
  $self->status == 0;
}

sub build_count_list {
  my ($self, $list) = @_;
  my @result = ();
  for (my $i = 1; $i < @$list; $i += 2) {
    push @result, { value => $list->[$i-1], count => $list->[$i] }
  }
  return \@result;
}

1;


package SolarBeam::Response;

use Mojo::Base -base;
use Data::Page;

has 'status';
has 'QTime';
has 'params';

has 'numFound';
has 'start';
has 'docs';

has 'facet_queries';
has 'facet_fields';
has 'facet_dates';
has 'facet_ranges';

has 'pager' => sub { Data::Page->new };

sub new {
  my ($class, $data) = @_;
  my $self = $class->SUPER::new;
  my $header = $data->{responseHeader};
  my $res = $data->{response};
  my $facets = $data->{facet_counts};
  my $field;

  if (!$header and !$res) {
    $self->status = 1;
    return $self;
  }

  for $field (keys %{$header}) {
    $self->$field($header->{$field});
  }

  for $field (keys %{$res}) {
    $self->$field($res->{$field});
  }

  for $field (keys %{$facets}) {
    $self->$field($facets->{$field});
  }
  
  if ($self->ok) {
    $self->pager->total_entries($self->numFound);
  }

  $self;
}

sub ok {
  my $self = shift;
  $self->status == 0;
}

1;


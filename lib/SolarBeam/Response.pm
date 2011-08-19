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

has 'terms';

has 'pager' => sub { Data::Page->new };

sub new {
  my ($class, $data) = @_;
  my $self = $class->SUPER::new;
  my $header = $data->{responseHeader};
  my $res = $data->{response};
  my $facets = $data->{facet_counts};
  my $terms = $data->{terms};
  my $field;

  if (!$header) {
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

  if ($terms) {
    my $sane_terms = {};
    for $field (keys %{$terms}) {
      my %values = @{$terms->{$field}};
      $sane_terms->{$field} = \%values;
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

1;


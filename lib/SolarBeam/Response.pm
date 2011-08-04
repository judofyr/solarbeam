package SolarBeam::Response;

use Mojo::Base -base;

has 'status';
has 'QTime';
has 'params';

has 'numFound';
has 'start';
has 'docs';

sub new {
  my ($class, $data) = @_;
  my $self = $class->SUPER::new;
  my $header = $data->{responseHeader};
  my $res = $data->{response};
  my $field;

  if (!$header and !$res) {
    die "Unknown response";
  }

  for $field (keys %{$header}) {
    $self->$field($header->{$field});
  }

  for $field (keys %{$res}) {
    $self->$field($res->{$field});
  }

  $self;
}

sub ok {
  my $self = shift;
  $self->status == 0;
}

1;


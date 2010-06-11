package Generic::RPG::Grid;

use Moose;

has grid => (
  is => 'rw',
  default => sub {[]},
);

1;

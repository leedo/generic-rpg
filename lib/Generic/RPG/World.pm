package Generic::RPG::World;

use Moose;
use Generic::RPG::Grid;

has players => (
  is => 'rw',
  isa => 'ArrayRef[Generic::RPG::Player]',
  default => sub {[]},
);

has npcs => (
  is => 'rw',
  isa => 'ArrayRef[Generic::RPG::NPC]',
  default => sub {[]},
);

has mobs => (
  is => 'rw',
  isa => 'ArrayRef[Generic::RPG::Mob]',
  default => sub {[]},
);

has grid => (
  is => 'rw',
  isa => 'Generic::RPG::Grid',
  default => sub {Generic::RPG::Grid->new},
);

has fields => (
  is => 'rw',
  isa => 'ArrayRef',
  auto_deref => 1,
  default => sub {[qw/mobs grid npcs players/]},
);

1;

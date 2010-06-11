package Generic::RPG;

use Moose;
use MooseX::Getopt;
use AnyEvent;
use Storable qw/freeze thaw/;
use Path::Class qw/file dir/;

use Generic::RPG::World;
use Generic::RPG::HTTP;
use Generic::RPG::Log qw/info debug error/;

has config_dir => (
  is => 'rw',
  default => sub {dir("$ENV{HOME}/.grpg")},
);

has state => (
  is => 'rw',
  lazy => 1,
  default => sub {file($_[0]->config_dir."/state")},
);

has world => (
  is => 'rw',
  isa => 'Generic::RPG::World',
  default => sub {Generic::RPG::World->new},
);

has ip => (
  is => 'ro',
  default => "0.0.0.0",
);

has port => (
  is => 'ro',
  default => 5000,
);

has http => (
  is => 'ro',
  lazy => 1,
  default => sub {
    Generic::RPG::HTTP->new(port => $_[0]->port, ip => $_[0]->ip);
  }
);

sub BUILD {
  my $self = shift;
  $self->config_dir->mkpath unless -e $self->config_dir;
  $self->load_state if -e $self->state;
  $self->http;
}

sub run {
  my $self = shift;
  my $cv = AE::cv;
  my $w = AnyEvent->signal(signal => "INT", cb => sub{print "\n"; $cv->send});
  $cv->wait;
  $self->save_state;
}

sub load_state {
  my $self = shift;
  info("loading config ".$self->state);
  my $state = thaw $self->state->slurp;
  $self->world->$_($state->{$_}) for $self->world->fields;
}

sub save_state {
  my $self = shift;
  info("saving state ".$self->state);
  my $fh = $self->state->openw;
  print $fh freeze {map {$_ => $self->world->$_} $self->world->fields};
}

1;

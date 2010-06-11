package Generic::RPG;

use Moose;
use MooseX::Getopt;
use AnyEvent;
use AnyEvent::DBI;
use Twiggy::Server;
use Plack::Request;
use Plack::Builder;
use Storable qw/freeze thaw/;
use Path::Class qw/file dir/;
use Generic::RPG::World;

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

has httpd => (
  is => 'ro',
  lazy => 1,
  default => sub {
    Twiggy::Server->new(
      host => $_[0]->ip,
      port => $_[0]->port,
    );
  }
);

sub BUILD {
  my $self = shift;
  $self->config_dir->mkpath unless -e $self->config_dir;
  -e $self->state ? $self->load_state : $self->save_state;
  $self->httpd->register_service($self->psgi_app);
}

sub run {
  my $self = shift;
  my $cv = AE::cv;
  my $w = AnyEvent->signal(signal => "INT", cb => sub{print "\n"; $cv->send});
  info("listening on port ".$self->ip.":".$self->port);
  $cv->wait;
  $self->save_state;
}

sub info {
  my @date = localtime(time);
  print "[$date[2]:$date[1]:$date[0] ";
  print "$date[4]/$date[3]/".($date[5]+1900)."] ";
  print join " ", @_;
  print "\n";
}

sub psgi_app {
  my $self = shift;
  builder {
    enable "StackTrace";
    enable "Lint";
    enable "+Web::Hippie";
    sub {$self->handle_request(@_)};
  }
}

sub handle_request {
  my ($self, $env) = @_;
  my $req = Plack::Request->new($env);
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

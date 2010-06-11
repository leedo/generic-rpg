package Generic::RPG::HTTP;

use Moose;
use Twiggy::Server;
use Plack::Request;
use Plack::Builder;
use Generic::RPG::Log qw/info debug error/;

has ip => (
  is => 'ro',
  required => 1,
);

has port => (
  is => 'ro',
  required => 1,
);

has httpd => (
  is => 'ro',
  lazy => 1,
  default => sub {
    info("listening on port ".$_[0]->ip.":".$_[0]->port);
    Twiggy::Server->new(
      host => $_[0]->ip,
      port => $_[0]->port,
    );
  }
);

sub BUILD {
  my $self = shift;
  $self->httpd;
  $self->httpd->register_service($self->app);
}

sub app {
  my $self = shift;
  builder {
    enable "StackTrace";
    enable "Lint";
    mount "/stream" => builder {
      enable "+Web::Hippie";
      sub {$self->handle_stream(@_)};
    };
    mount "/" => builder {
      sub {$self->handle_request(@_)};
    };
  }
}

sub handle_stream {
  my ($self, $env) = @_;
  my $args = $env->{'hippie.args'};
  my $handle = $env->{'hippie.handle'};
  print STDERR $handle;
}

sub handle_request {
  my ($self, $env) = @_;
  my $req = Plack::Request->new($env);
}

1;

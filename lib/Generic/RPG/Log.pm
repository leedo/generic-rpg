package Generic::RPG::Log;

use base 'Exporter';
our @EXPORT_OK = qw/info debug error/;

sub info { _print("info", @_) }
sub debug { _print("debug", @_) }
sub error { _print("error", @_) }

sub _print {
  my $level = shift;
  my @date = localtime(time);
  print "[$date[2]:$date[1]:$date[0] ";
  print "$date[4]/$date[3]/".($date[5]+1900)."] ";
  print join " ", @_;
  print "\n";
}

1;

#!/usr/bin/perl
use forks;
use forks::shared;
#threads->debug( 1 );
package Latch::Manager;
use Mouse;
use feature 'say';
use Data::Dumper;
use File::Basename qw(dirname);
use File::Path qw(make_path);
extends qw(Latch Latch::Dance);

sub latch_start {
  my ($class, $args) = @_;
  my $logfiles;
  $class->{myThreads}->{$args->{latchID}} = threads->create(
    sub {
      make_path($args->{logdir}) if (!-d $args->{logdir});
      open STDOUT, '>>', $args->{logdir} . "/sdtout.log" or die $!;
      open STDERR, '>>', $args->{logdir} . "/stderr.log" or die $!;
      my $owntid = threads->tid;
      use Latch::Dance;
      use Dancer2;
      my $dance = Latch::Dance->new->gets() or die "$!\n";
      set server  => $args->{ipv4_address};
      set port  => $args->{port};
      set startup_info => (defined($args->{dancer_startup_info})) ? $args->{dancer_startup_info}  : 1;
      #set appdir => '';
      $0 = $args->{proc_name} if defined($args->{proc_name});
      start or die "$!\n";
  });
  return $class;
}

sub latch_stop {
  my $class = shift;
  return $class;
}

sub latch_reload {
  my $class = shift;
  return $class;
}

sub latch_status {
  my $class = shift;
  return $class;
}

__PACKAGE__->meta->make_immutable;

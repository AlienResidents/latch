#!/usr/bin/perl
use forks;
use forks::shared;
use warnings;
use strict;
use diagnostics;
use feature 'say';
use lib qw(/home/cdd/latch/lib);
use Latch::Manager;
use JSON;
use Data::Dumper;
use Encode;
use Time::HiRes;
use File::Basename;
use Proc::Daemon;
use Cwd;
use Getopt::Long;
use Data::Compare;
use Sys::Hostname;
$| = 1;


my $continue = 1;
my $debug = 0;
my $latch_mg = Latch::Manager->new();

my $latch_cfg = (defined($ARGV[0]) && -f $ARGV[0]) ? $ARGV[0] : '/usr/local/etc/latch-cfg.json';
$latch_mg = $latch_mg->get_json_cfg({config => $latch_cfg}) or die "$!\n";
if ($latch_mg->{json_data}->{my_self}->{hostname} ne hostname) {
  say "This host (" . hostname . ") does not seem to be configured";
  exit 100;
}
say $latch_mg->{json_data}->{my_self}->{hostname} if $debug;

make_path($latch_mg->{json_data}->{my_self}->{logdir}) if (!-d $latch_mg->{json_data}->{my_self}->{logdir});
open STDOUT, '>>', $latch_mg->{json_data}->{my_self}->{logdir} . "/sdtout.log" or die $!;
open STDERR, '>>', $latch_mg->{json_data}->{my_self}->{logdir} . "/stderr.log" or die $!;
say Dumper $latch_mg if $debug;

my $chroot_base = $latch_mg->{json_data}->{my_self}->{chroot_basedir};
my $logdir = "$chroot_base/" . $latch_mg->{json_data}->{my_self}->{logdir};

# We 'could' change our hostname while running, we shouldn't be ok with
# this, and hence we check again and again, over and over etc etc
  #say Dumper $latch_mg->{my_self}->{ourLatches};
  #say Dumper $latch_mg->{boots};
  #say "hello " . $latch_mg->date;

my @ports_used;
my $manager;
my @ourLatches;
my $myThreads;
my $latches = $latch_mg->{json_data}->{my_self}->{ourLatches};
while ($continue) {
  foreach my $latches (@{$latch_mg->{json_data}->{my_self}->{ourLatches}}) {
    my $latchID = "latch-" . $latches->{color} . "-" . $latches->{vcs_ver};
    my $logdir = "$logdir/latch-" . $latches->{color} . "-" . $latches->{vcs_ver};
    say "============== $logdir ============" if $debug;
    if (!grep(/$latches->{port}/, @ports_used)) {
      $latch_mg->{$latchID} = $latch_mg->latch_start({
        appdir              => '',
        port                => $latches->{port},
        ipv4_address        => $latches->{ipv4_address},
        latchID             => $latchID,
        proc_name           => "atch :: " .
          $latchID . " :: " .
          uc($latches->{proto}) . ":" .
          $latches->{ipv4_address} . ":" .
          $latches->{port},
        logdir              => $logdir,
        dancer_startup_info => 0,
      }) or die "$!\n";
      push(@ports_used, $latches->{port});
    }
  }

  sleep 1;
  say Dumper $latch_mg if $debug;
  my @running = threads->list(threads::running);
  say "Threads Running: " . threads->list(threads::running);
  $_->join() foreach (threads->list(threads::joinable));
  $_->join foreach threads->list;

  say "All Threads should be done.";
  say "Threads Running: " . threads->list(threads::running);
  $continue = 0;
}

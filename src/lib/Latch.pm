#!/usr/bin/perl
package Latch;
use forks;
use forks::shared;
use Mouse;
use File::Basename;
use feature 'say';
use JSON;
use IO::File;
use Data::Dumper;
use sigtrap 'handler' => \&sig_handler, 'normal-signals';

sub date {
  return localtime(time);
}

sub get_json_cfg {
  my ($class, $args) = @_;
  if (defined($args->{config})) {
    my $fh = IO::File->new($args->{config}) or die "Cannot read config file: " . $args->{config} . ": $!";
    local $/ = undef;
    my $json_cfg = <$fh>;
    close($fh);
    my $json = JSON->new->indent->relaxed(0)->canonical(1);
    my $json_text = $json->pretty(0)->encode(from_json($json_cfg));
    my $json_data = $json->utf8(0)->decode($json_text);
    $class->{json_data} = $json_data;
  }
  return $class;
}

sub sig_handler {
  my ($signal) = @_;
  say "Signal received ($signal), exiting";
  exit;
}

sub check_cfg {
  my ($class, $args) = @_;
  my $result;
  use Data::Compare;
  my $new_latch_mg = get_json_cfg({config => $args->{latch_cfg}}) or die "$!\n";
  if (!Compare($args->{latch_mg}, $new_latch_mg)) {
    $result = 1;
  }
  return ($result, $new_latch_mg);
}

__PACKAGE__->meta->make_immutable;

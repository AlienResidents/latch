#!/usr/bin/perl
package Latch::Dance;
use Mouse;
use Dancer2;
extends qw(Latch);

sub gets {
  my ($class, %args) = @_;
  get '/' => sub { return 'Hello World!'; };
  get '/test' => sub { return 'Test World!'; };
  return $class;
}

__PACKAGE__->meta->make_immutable;

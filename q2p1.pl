#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %grid;

my ($sx, $sy);
while (<>) {
    chomp;
    if (-1 != (my $x = index $_, '@')) {
        $grid{$.}{$x} = '@';
        $sx = $x;
        $sy = $.;
    }
    if (-1 != (my $x = index $_, '#')) {
        $grid{$.}{$x} = '#';
    }
}

my @MOVES = ([-1, 0], [0, 1], [1, 0], [0, -1]);
my $move = 0;
my $steps = 0;
while (1) {
    my ($my, $mx) = @{ $MOVES[$move++ % 4] };
    my $ny = $sy + $my;
    my $nx = $sx + $mx;

    redo if '@' eq ($grid{$ny}{$nx} // "");
    last if '#' eq ($grid{$ny}{$nx} // "");

    $grid{$ny}{$nx} = '@';
    ($sy, $sx) = ($ny, $nx);
    ++$steps;
    warn "$steps: $sy $sx";
}
say 1 + $steps;

__DATA__
.......
.......
.......
.#.@...
.......
.......
.......

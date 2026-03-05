#!/usr/bin/perl
use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

use ARGV::OrDATA;

sub show($grid) {
    my ($min_y, $max_y) = (sort { $a <=> $b } keys %$grid)[0, -1];
    my ($min_x, $max_x) = (sort { $a <=> $b }
                           map keys %{ $grid->{$_} },
                           keys %$grid
                          )[0, -1];
    for my $y ($min_y .. $max_y) {
        for my $x ($min_x .. $max_x) {
            print $grid->{$y}{$x} // '.';
        }
        print "\n";
    }
}

my @MOVES = ([-1, 0], [0, 1], [1, 0], [0, -1]);

sub fill($grid) {
    my ($min_y, $max_y) = (sort { $a <=> $b } keys %$grid)[0, -1];
    my ($min_x, $max_x) = (sort { $a <=> $b }
                           map keys %{ $grid->{$_} },
                           keys %$grid
                          )[0, -1];
    for my $gy (keys %$grid)  {
        for my $gx (keys %{ $grid->{$gy} }) {
            for my $m (@MOVES) {
                my $y = $gy + $m->[0];
                my $x = $gx + $m->[1];
                flood($grid, $y, $x, $min_y, $max_y, $min_x, $max_x)
                    unless exists $grid->{$y}{$x};
            }
        }
    }
}

sub flood($grid, $y, $x, $min_y, $max_y, $min_x, $max_x) {
    my %agenda = ("$y:$x" => undef);
    my %flood = %agenda;
    while (keys %agenda) {
        my %next;
        for my $yx (keys %agenda) {
            my ($y, $x) = split /:/, $yx;
            for my $m (@MOVES) {
                my $ny = $y + $m->[0];
                return if $ny < $min_y || $ny > $max_y;

                my $nx = $x + $m->[1];
                return if $nx < $min_x || $nx > $max_x;

                undef $flood{"$ny:$nx"}, undef $next{"$ny:$nx"}
                    unless exists $grid->{$ny}{$nx};
            }
        }
        %agenda = %next;
    }
    for my $yx (keys %flood) {
        my ($y, $x) = split /:/, $yx;
        $grid->{$y}{$x} = '@';
    }
}

my %grid;

my ($sx, $sy, $ex, $ey);
while (<>) {
    chomp;
    if (-1 != (my $x = index $_, '@')) {
        $grid{$.}{$x} = '@';
        $sx = $x;
        $sy = $.;
    }
    if (-1 != (my $x = index $_, '#')) {
        $grid{$.}{$x} = '#';
        $ex = $x;
        $ey = $.;
        
    }
}

my $move = 0;
my $steps = 0;
while (1) {
    my ($my, $mx) = @{ $MOVES[$move++ % 4] };
    my $ny = $sy + $my;
    my $nx = $sx + $mx;

    redo if ($grid{$ny}{$nx} // "") =~ /[#@]/;

    $grid{$ny}{$nx} = '@';
    last if '@' eq ($grid{ $ey + 1 }{$ex} // "")
         && '@' eq ($grid{ $ey - 1 }{$ex} // "")
         && '@' eq ($grid{$ey}{ $ex + 1 } // "")
         && '@' eq ($grid{$ey}{ $ex - 1 } // "");

    ($sy, $sx) = ($ny, $nx);
    ++$steps;
    warn "$steps: $sy $sx";
    fill(\%grid);
    show(\%grid);
    $grid{$ny}{$nx} = '@';
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

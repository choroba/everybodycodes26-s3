#!/usr/bin/perl
use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

use ARGV::OrDATA;

sub show($grid, $surrounds) {
    my ($min_y, $max_y) = (sort { $a <=> $b } keys %$grid)[0, -1];
    my ($min_x, $max_x) = (sort { $a <=> $b }
                           map keys %{ $grid->{$_} },
                           keys %$grid
                          )[0, -1];
    say "$min_y $min_x";
    for my $y ($min_y .. $max_y) {
        for my $x ($min_x .. $max_x) {
            print $grid->{$y}{$x} // (exists $surrounds->{"$y:$x"} ? 'o' : '.');
        }
        print "\n";
    }
}

my @DIRS = ([-1, 0], [0, 1], [1, 0], [0, -1]);

sub fill($grid, $sy, $sx, $surrounds) {
    my ($min_y, $max_y) = (sort { $a <=> $b } keys %$grid)[0, -1];
    my ($min_x, $max_x) = (sort { $a <=> $b }
                           map keys %{ $grid->{$_} },
                           keys %$grid
                          )[0, -1];
    for my $gy ($min_y .. $max_y)  {
        for my $gx ($min_x .. $max_x) {
            flood($grid, $gy, $gx, $min_y, $max_y, $min_x, $max_x, $surrounds)
                unless exists $grid->{$gy}{$gx};
        }
    }
}

sub flood($grid, $y, $x, $min_y, $max_y, $min_x, $max_x, $surrounds) {
    my %agenda = ("$y:$x" => undef);
    my %flood = %agenda;
    while (keys %agenda) {
        my %next;
        for my $yx (keys %agenda) {
            my ($y, $x) = split /:/, $yx;
            for my $m (@DIRS) {
                my $ny = $y + $m->[0];
                return if $ny < $min_y || $ny > $max_y;

                my $nx = $x + $m->[1];
                return if $nx < $min_x || $nx > $max_x;

                undef $flood{"$ny:$nx"}, undef $next{"$ny:$nx"}
                    unless exists $grid->{$ny}{$nx} || exists $flood{"$ny:$nx"};
            }
        }
        %agenda = %next;
    }
    for my $yx (keys %flood) {
        my ($y, $x) = split /:/, $yx;
        $grid->{$y}{$x} = '@';
        delete $surrounds->{$yx};
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
    while (/#/g) {
        my $x = pos() - 1;
        $grid{$.}{$x} = '#';
        $ex = $x;
        $ey = $.;
        
    }
}

my %surrounds;
for my $y (keys %grid) {
    for my $x (keys %{ $grid{$y} }) {
        next unless $grid{$y}{$x} eq '#';

        for my $m (@DIRS) {
            my $sy = $y + $m->[0];
            my $sx = $x + $m->[1];
            undef $surrounds{"$sy:$sx"} if '#' ne ($grid{$sy}{$sx} // "");
        }
    }
}
delete $surrounds{"$sy:$sx"};

my @MOVES = map +($_) x 3, @DIRS;

my $move = 0;
my $steps = 0;
while (1) {
    my ($my, $mx) = @{ $MOVES[$move++ % @MOVES] };
    my $ny = $sy + $my;
    my $nx = $sx + $mx;

    redo if ($grid{$ny}{$nx} // "") =~ /[#@]/;
    ++$steps;


    $grid{$ny}{$nx} = '@';
    delete $surrounds{"$ny:$nx"};
    last if ! keys %surrounds;

    ($sy, $sx) = ($ny, $nx);
    warn "$steps: $sy $sx";
    fill(\%grid, $sy, $sx, \%surrounds);
    last if ! keys %surrounds;
    $grid{$ny}{$nx} = '+';
    show(\%grid, \%surrounds);
    $grid{$ny}{$nx} = '@';
}
say $steps;

__DATA__
.......
.......
.......
.#.@...
.......
.......
.......


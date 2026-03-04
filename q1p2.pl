#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %BIN = (r => 0, g => 0, b => 0, s => 0,
           R => 1, G => 1, B => 1, S => 1);

my @max_shine = ([-1]);
while (<>) {
    chomp;
    my ($id, $red, $green, $blue, $shine)
        = /^(\d+):([Rr]+) ([Gg]+) ([Bb]+) ([Ss]+)$/
        or die "Can't parse.";

    $_ = unpack 'W*', pack 'B6', s{(.)}{$BIN{$1}}gr
        for $red, $green, $blue, $shine;
    if ($shine >= $max_shine[0][0]) {
        @max_shine = () if $shine > $max_shine[0][0];
        push @max_shine, [$shine, $id, $red + $green + $blue];
    }
}
say +(sort { $a->[2] <=> $b->[2] } @max_shine)[0][1];

__DATA__
2456:rrrrrr ggGgGG bbbbBB sSsSsS
7689:rrRrrr ggGggg bbbBBB ssSSss
3145:rrRrRr gggGgg bbbbBB sSsSsS
6710:rrrRRr ggGGGg bbBBbB ssSSss

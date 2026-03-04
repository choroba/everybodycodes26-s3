#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ sum };

my %BIN = (r => 0, g => 0, b => 0, s => 0,
           R => 1, G => 1, B => 1, S => 1);

my @groups;
while (<>) {
    chomp;
    my ($id, $red, $green, $blue, $shine)
        = /^(\d+):([Rr]+) ([Gg]+) ([Bb]+) ([Ss]+)$/
        or die "Can't parse.";

    $_ = unpack 'W*', pack 'B8', '00' . s{(.)}{$BIN{$1}}gr
        for $red, $green, $blue, $shine;
    next if 30 < $shine && $shine < 33;  # Neither matte nor shiny.

    my @s = sort { $b->[0] <=> $a->[0] } [$red, 0], [$green, 1], [$blue, 2];
    next if $s[0][0] == $s[1][0];  # No dominant colour.

    push @{ $groups[$shine <= 30][ $s[0][1] ] }, $id;
}
my ($size, $sum) = (0, 0);
for my $group (map @$_, @groups) {
    ($size, $sum) = (scalar @$group, sum(@$group)) if @$group > $size;
}
say $sum;

__DATA__
15437:rRrrRR gGGGGG BBBBBB sSSSSS
94682:RrRrrR gGGggG bBBBBB ssSSSs
56513:RRRrrr ggGGgG bbbBbb ssSsSS
76346:rRRrrR GGgggg bbbBBB ssssSs
87569:rrRRrR gGGGGg BbbbbB SssSss
44191:rrrrrr gGgGGG bBBbbB sSssSS
49176:rRRrRr GggggG BbBbbb sSSssS
85071:RRrrrr GgGGgg BBbbbb SSsSss
44303:rRRrrR gGggGg bBbBBB SsSSSs
94978:rrRrRR ggGggG BBbBBb SSSSSS
26325:rrRRrr gGGGgg BBbBbb SssssS
43463:rrrrRR gGgGgg bBBbBB sSssSs
15059:RRrrrR GGgggG bbBBbb sSSsSS
85004:RRRrrR GgGgGG bbbBBB sSssss
56121:RRrRrr gGgGgg BbbbBB sSsSSs
80219:rRRrRR GGGggg BBbbbb SssSSs

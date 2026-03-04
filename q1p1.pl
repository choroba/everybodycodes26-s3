#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %BIN = (r => 0, g => 0, b => 0,
           R => 1, G => 1, B => 1);

my $sum = 0;
while (<>) {
    chomp;
    my ($id, $red, $green, $blue) = /^(\d+):([Rr]+) ([Gg]+) ([Bb]+)$/
        or die "Can't parse.";

    $_ = pack 'B6', s{(.)}{$BIN{$1}}gr for $red, $green, $blue;
    $sum += $id if $green gt $red && $green gt $blue;
}
say $sum;

__DATA__
2456:rrrrrr ggGgGG bbbbBB
7689:rrRrrr ggGggg bbbBBB
3145:rrRrRr gggGgg bbbbBB
6710:rrrRRr ggGGGg bbBBbB

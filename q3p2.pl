#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;
use List::Util qw{ sum };

use enum qw( ID PLUG LEFT_S RIGHT_S LEFT RIGHT );

sub plug($tree, $id, $plug, $left, $right) {
    if (! $tree->[LEFT] && match($tree->[LEFT_S], $plug)) {
        $tree->[LEFT] = [$id, $plug, $left, $right];
        return 1
    }
    return 1 if $tree->[LEFT] && plug($tree->[LEFT], $id, $plug, $left, $right);

    if (! $tree->[RIGHT] && match($tree->[RIGHT_S], $plug)) {
        $tree->[RIGHT] = [$id, $plug, $left, $right];
        return 1
    }
    return 1
        if $tree->[RIGHT] && plug($tree->[RIGHT], $id, $plug, $left, $right);

    return
}

sub match($socket, $plug) {
    my ($socket_color, $socket_shape) = split ' ', $socket;
    my ($plug_color, $plug_shape) = split ' ', $plug;
    return $socket_color eq $plug_color || $socket_shape eq $plug_shape
}

sub walk($tree) {
    my @seq = _walk($tree);
    my $i = 1;
    return sum(map $_ * $i++, @seq)
}

sub _walk($tree) {
    my @seq;
    push @seq, _walk($tree->[LEFT]) if $tree->[LEFT];
    push @seq, $tree->[ID];
    push @seq, _walk($tree->[RIGHT]) if $tree->[RIGHT];
    return @seq
}

my $tree;
while (<>) {
    chomp;
    /id=([^,]+), plug=([^,]+), leftSocket=([^,]+), rightSocket=([^,]+), data=.*/
        or die "Can't parse";
    my ($id, $plug, $left, $right) = @{^CAPTURE};
    if ($tree) {
        plug($tree, $id, $plug, $left, $right);
    } else {
        $tree = [$id, $plug, $left, $right];
    }
}

say walk($tree);

__DATA__
id=1, plug=RED TRIANGLE, leftSocket=RED TRIANGLE, rightSocket=RED TRIANGLE, data=?
id=2, plug=GREEN TRIANGLE, leftSocket=BLUE CIRCLE, rightSocket=GREEN CIRCLE, data=?
id=3, plug=BLUE PENTAGON, leftSocket=BLUE CIRCLE, rightSocket=GREEN CIRCLE, data=?
id=4, plug=RED TRIANGLE, leftSocket=BLUE PENTAGON, rightSocket=GREEN PENTAGON, data=?
id=5, plug=RED PENTAGON, leftSocket=GREEN CIRCLE, rightSocket=GREEN CIRCLE, data=?

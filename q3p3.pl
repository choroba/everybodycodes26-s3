#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;
use List::Util qw{ sum };

use enum qw( ID PLUG LEFT_S RIGHT_S LEFT RIGHT IS_ROOT );

sub plug($tree, $node_ref, $again = 0) {
    if (! $tree->[LEFT] && match($tree->[LEFT_S], $$node_ref->[PLUG])) {
        $tree->[LEFT] = $$node_ref;
        warn "$$node_ref->[ID] into L $tree->[ID]";
        return 1
    }
    warn "no match: $$node_ref->[ID] into L $tree->[ID]";

    if ($tree->[LEFT] && 1 == match($tree->[LEFT_S], $tree->[LEFT][PLUG])
        && 2 == match($tree->[LEFT_S], $$node_ref->[PLUG])
    ) {
        my $disconnect = $tree->[LEFT];
        warn "kick $disconnect->[ID] from L $tree->[ID] by $$node_ref->[ID]";
        $tree->[LEFT] = $$node_ref;
        $$node_ref = $disconnect;
    } elsif ($tree->[LEFT] && plug($tree->[LEFT], $node_ref)) {
        return 1
    }

    if (! $tree->[RIGHT] && match($tree->[RIGHT_S], $$node_ref->[PLUG])) {
        $tree->[RIGHT] = $$node_ref;
        warn "$$node_ref->[ID] into R $tree->[ID]";
        return 1
    }
    warn "no match: $$node_ref->[ID] into R $tree->[ID]";

    if ($tree->[RIGHT] && 1 == match($tree->[RIGHT_S], $tree->[RIGHT][PLUG])
        && 2 == match($tree->[RIGHT_S], $$node_ref->[PLUG])
    ) {
        my $disconnect = $tree->[RIGHT];
        warn "kick $disconnect->[ID] from R $tree->[ID] by $$node_ref->[ID]";
        $tree->[RIGHT] = $$node_ref;
        $$node_ref = $disconnect;

    } elsif ($tree->[RIGHT] && plug($tree->[RIGHT], $node_ref)) {
        return 1
    }

    if ($tree->[IS_ROOT]) {
        die "Nowhere to attach $$node_ref->[ID]" if $again;
        warn "retry $$node_ref->[ID]";
        return plug($tree, $node_ref, 1);
    }

    return
}

sub match($socket, $plug) {
    my ($socket_color, $socket_shape) = split ' ', $socket;
    my ($plug_color, $plug_shape) = split ' ', $plug;
    return ($socket_color eq $plug_color) + ($socket_shape eq $plug_shape)
}

sub walk($tree) {
    my @seq = _walk($tree);
    warn "@seq";
    my $i = 1;
    return sum(map $_ * $i++, @seq)
}

sub _walk($tree) {
    my @seq;
    say("$tree->[ID] \-> $tree->[LEFT][ID] \[label=L];"),
    push @seq, _walk($tree->[LEFT]) if $tree->[LEFT];
    push @seq, $tree->[ID];
    say("$tree->[ID] \-> $tree->[RIGHT][ID] \[label=R];"),
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
        plug($tree, \[$id, $plug, $left, $right]) or die "Can't plug";
    } else {
        $tree = [$id, $plug, $left, $right, undef, undef, 1];
    }
}

say walk($tree);

__DATA__
id=1, plug=RED TRIANGLE, leftSocket=RED TRIANGLE, rightSocket=RED TRIANGLE, data=?
id=2, plug=GREEN TRIANGLE, leftSocket=BLUE CIRCLE, rightSocket=GREEN CIRCLE, data=?
id=3, plug=BLUE PENTAGON, leftSocket=BLUE CIRCLE, rightSocket=GREEN CIRCLE, data=?
id=4, plug=RED TRIANGLE, leftSocket=BLUE PENTAGON, rightSocket=GREEN PENTAGON, data=?
id=5, plug=RED PENTAGON, leftSocket=GREEN CIRCLE, rightSocket=GREEN CIRCLE, data=?

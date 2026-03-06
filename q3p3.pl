#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;
use List::Util qw{ sum };

use enum qw( ID PLUG LEFT_S RIGHT_S LEFT RIGHT IS_ROOT );

sub plug($tree, $node_ref, $again = 0) {
    for my $side ([LEFT, LEFT_S, 'L'],
                  [RIGHT, RIGHT_S, 'R']
    ) {
        my ($child, $child_s, $label) = @$side;
        if (! $tree->[$child] && match($tree->[$child_s], $$node_ref->[PLUG])) {
            $tree->[$child] = $$node_ref;
            warn "$$node_ref->[ID] into $label $tree->[ID]";
            return 1
        }
        warn "no match: $$node_ref->[ID] into $label $tree->[ID]";

        if ($tree->[$child]
            && 1 == match($tree->[$child_s], $tree->[$child][PLUG])
            && 2 == match($tree->[$child_s], $$node_ref->[PLUG])
        ) {
            my $disconnect = $tree->[$child];
            warn "kick $disconnect->[ID] from $label "
                 . "$tree->[ID] by $$node_ref->[ID]";
            $tree->[$child] = $$node_ref;
            $$node_ref = $disconnect;

        } elsif ($tree->[$child] && plug($tree->[$child], $node_ref)) {
            return 1
        }
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

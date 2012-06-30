package PulseMeter::Sensor::Timelined::Percentile;
use strict;
use warnings 'all';
use Data::Uniqid qw/uniqid/;

use base qw/PulseMeter::Sensor::Timeline/;

sub aggregate_event {
    my ($self, $key, $value) = @_;
    $self->r->zadd(
        $key,
        $value,
        sprintf("%s::%s", $value, uniqid())
    );
}

1;

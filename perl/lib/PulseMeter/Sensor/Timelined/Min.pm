package PulseMeter::Sensor::Timelined::Min;
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
    $self->r->zremrangebyrank($key, 1, -1);
}

1;

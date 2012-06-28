package PulseMeter::Sensor::Timelined::Average;
use strict;
use warnings 'all';

use base qw/PulseMeter::Sensor::Timeline/;

sub aggregate_event {
    my ($self, $key, $value) = @_;
    $self->r->hincrby($key, "count", 1);
    $self->r->hincrby($key, "sum", $value);
}

1;

package PulseMeter::Sensor::Timelined::UniqCounter;
use strict;
use warnings 'all';
use Data::Uniqid qw/uniqid/;

use base qw/PulseMeter::Sensor::Timeline/;

sub aggregate_event {
    my ($self, $key, $value) = @_;
    $self->r->sadd($key, $value);
}

1;

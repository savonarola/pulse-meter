package PulseMeter::Sensor::Timelined::HashedCounter;
use strict;
use warnings 'all';

use base qw/PulseMeter::Sensor::Timeline/;

sub aggregate_event {
    my ($self, $key, $data) = @_;
    $self->r->hincrby($key, $_, $data->{$_}) for (keys(%$data));
}

1;

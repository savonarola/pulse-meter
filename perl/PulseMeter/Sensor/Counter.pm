package PulseMeter::Sensor::Counter;
use strict;
use warnings 'all';

use base qw/PulseMeter::Sensor::Base/;

sub event {
    my ($self, $value) = @_;
    $self->r->incrby($self->value_key, $value);
}

sub incr { shift->event(1) }

sub value_key {
    my $self = shift;
    sprintf("pulse_meter:value:%s", $self->name);
}

1;

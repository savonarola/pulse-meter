package PulseMeter::Sensor::Indicator;
use strict;
use warnings 'all';

use base qw/PulseMeter::Sensor::Base/;

sub event {
    my ($self, $value) = @_;
    $self->r->set($self->value_key, $value);
}

sub value_key {
    my $self = shift;
    sprintf("pulse_meter:value:%s", $self->name);
}

1;

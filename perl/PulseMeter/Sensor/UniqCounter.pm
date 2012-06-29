package PulseMeter::Sensor::UniqCounter;
use strict;
use warnings 'all';

use base qw/PulseMeter::Sensor::Counter/;

sub event {
    my ($self, $value) = @_;
    $self->r->sadd($self->value_key, $value);
}

1;

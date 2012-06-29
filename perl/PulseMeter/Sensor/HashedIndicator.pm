package PulseMeter::Sensor::HashedIndicator;
use strict;
use warnings 'all';

use base qw/PulseMeter::Sensor::Indicator/;

sub event {
    my ($self, $data) = @_;
    $self->r->hset($self->value_key, $_, $data->{$_}) for (keys %$data);
}

1;

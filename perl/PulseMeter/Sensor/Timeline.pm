package PulseMeter::Sensor::Timeline;
use strict;
use warnings 'all';

use base qw/PulseMeter::Sensor::Base/;

use constant DEFAULTS => {
    raw_data_ttl => 3600,
    interval => 60,
};

sub init {
    my $self = shift;
    my $name = shift;
    $self->SUPER::init($name, @_);
    my $opts = {@_};
    $self->{$_} = $opts->{$_} || DEFAULTS->{$_} for qw/raw_data_ttl interval/;
}

sub raw_data_ttl { shift->{raw_data_ttl} }
sub interval { shift->{interval} }

sub event {
    my ($self, $value) = @_;
    $self->r->multi;
    my $current_key = $self->current_raw_data_key;
    $self->aggregate_event($current_key, $value);
    $self->r->expire($current_key, $self->raw_data_ttl);
    $self->r->exec;
}

sub raw_data_key {
    my ($self, $id) = @_;
    sprintf("pulse_meter:raw:%s:%s", $self->name, $id);
}

sub get_interval_id {
    my ($self, $time) = @_;
    int($time / $self->interval) * $self->interval;
}

sub current_interval_id { shift->get_interval_id(time) }

sub current_raw_data_key {
    my $self = shift;
    $self->raw_data_key($self->current_interval_id);
}

sub aggregate_event { die('Abstract') }

1;

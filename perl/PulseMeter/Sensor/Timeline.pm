package PulseMeter::Sensor::Timeline;
use strict;
use warnings 'all';

use Data::Dumper;
use Redis;

use constant DEFAULTS => {
    raw_data_ttl => 3600,
    interval => 60,
    redis => {
        host => 'localhost',
        port => 6379,
        db => 0
    }
};

sub new {
    my $class = shift;
    my $self = {};
    bless($self, $class);
    $self->init(@_);
    return $self;
}

sub init {
    my $self = shift;
    my $name = shift;
    my $opts = {@_};

    my $redis_options = $opts->{redis} || {};
    $redis_options->{$_} ||= DEFAULTS->{redis}->{$_} for qw/host port db/;
    my $redis = Redis->new(
         server => sprintf("%s:%s", $redis_options->{host}, $redis_options->{port})
    );
    $redis->select($redis_options->{db});
    $self->{redis} = $redis;

    $self->{name} = $name;
    $self->{$_} = $opts->{$_} || DEFAULTS->{$_} for qw/raw_data_ttl interval/;
}

sub r { shift->{redis} }
sub raw_data_ttl { shift->{raw_data_ttl} }
sub interval { shift->{interval} }
sub name { shift->{name} }

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

sub current_interval_id {
    my $self = shift;
    $self->get_interval_id(time);
}

sub current_raw_data_key {
    my $self = shift;
    $self->raw_data_key($self->current_interval_id);
}

sub aggregate_event { die('Abstract') }

1;

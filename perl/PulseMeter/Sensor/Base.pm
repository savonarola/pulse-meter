package PulseMeter::Sensor::Base;
use strict;
use warnings 'all';

use base qw/Exporter/;
use Data::Dumper;
use Redis;

use constant REDIS_DEFAULTS => {
    host => 'localhost',
    port => 6379,
    db => 0
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
    $redis_options->{$_} ||= REDIS_DEFAULTS->{$_} for qw/host port db/;
    my $redis = Redis->new(
         server => sprintf("%s:%s", $redis_options->{host}, $redis_options->{port})
    );
    $redis->select($redis_options->{db});
    $self->{redis} = $redis;

    $self->{name} = $name;
}

sub r { shift->{redis} }
sub name { shift->{name} }

1;

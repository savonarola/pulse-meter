#!perl

use warnings;
use strict;
use lib '../lib'; #TODO remove
use Test::More;
use Redis;
use PulseMeter::Sensor::HashedIndicator;

my $s = PulseMeter::Sensor::HashedIndicator->new("foo");
my $r = Redis->new;
    
subtest 'describe .event' => sub {
    $s->redis->flushdb;
    my $data = {1 => 10, 2 => 20};
    $s->event($data);
    is_deeply(
        {$r->hgetall($s->value_key)},
        $data,
        "it saves multiple values"
    );
};

done_testing();

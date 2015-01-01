#!perl -T

use strict;
use warnings FATAL => 'all';

use Test::More;

plan tests => 4;

use_ok('Spotify::Control');

my $spot = Spotify::Control->new;
isa_ok($spot, 'Spotify::Control', 'Spotify::Control->new returns a Spotify::Control');

my $status;
eval { $status = $spot->status };
is($@, '', 'Spotify::Control->status returned successfully');
isa_ok($status, 'HASH', 'Spotify::Control->status returned a HASH');

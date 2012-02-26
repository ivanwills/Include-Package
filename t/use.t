#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1 + 1;
use Test::NoWarnings;
use Path::Class;
use Include::Package qw/load/;

push @INC, file(__FILE__)->parent->subdir('lib');

my $ip = Include::Package::load('ip-test', '== 1.0', 'BLAH');

$ip->use('IP::Test');

is($IP::Test::VERSION, 1.0, 'Have the appropriate package loaded');

#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 11 + 1;
use Test::NoWarnings;
use Path::Class;
use Include::Package qw/load/;

push @INC, file(__FILE__)->parent->subdir('lib');

scalar_tests();
array_tests();
hash_tests();

sub scalar_tests {
    my $ip = Include::Package::load('ip-test', undef, 'BLAH');

    isa_ok($ip, 'Include::Package', 'Can load a package');
    is($ip->version, '2.0', 'Gets the newest dist version');

    $ip = Include::Package::load('ip-test', '== 1.0', 'ONE');

    isa_ok($ip, 'Include::Package', 'Can load a package');
    is($ip->version, '1.0', 'Gets the dist version 1.0');

    $ip = Include::Package::load('ip-test', '> 1.5', 'ONE');
    is($ip->version, '2.0', 'Gets the dist version 1.0');

    $ip = Include::Package::load('ip-test', '< 1.5', 'ONE');
    is($ip->version, '1.0', 'Gets the dist version 1.0');

    $ip = Include::Package::load('ip-test', '<= 1.5', 'ONE');
    is($ip->version, '1.5', 'Gets the dist version 1.5');

    $ip = Include::Package::load('ip-test', '>= 1.5', 'ONE');
    is($ip->version, '2.0', 'Gets the dist version 2.0');

    eval { Include::Package::load('ip-test', '> 2.5', 'ONE') };
    ok($@, 'Can\'t find higher version');

    eval { Include::Package::load('ip-test', '< 0.5', 'ONE') };
    ok($@, 'Can\'t find lower version');

    $ip = Include::Package::load('ip-test', '!= 2.0', 'ONE');
    is($ip->version, '1.5', 'Gets the dist version 1.5');
}

sub array_tests {
}

sub hash_tests {
}

#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1 + 1;
use Test::NoWarnings;

BEGIN {
	use_ok( 'Include::Package' );
}

diag( "Testing Include::Package $Include::Package::VERSION, Perl $], $^X" );

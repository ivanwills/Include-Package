package Include::Package;

# Created on: 2012-02-20 20:29:10
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use version;
use Carp;
use Scalar::Util;
use List::Util;
#use List::MoreUtils;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;


our $VERSION     = version->new('0.0.1');
our @EXPORT_OK   = qw/load/;
our %EXPORT_TAGS = ();
#our @EXPORT      = qw//;
our %distributions;

has file => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);
has distribution => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);
has version => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);
has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);
has package => (
    is       => 'rw',
    isa      => 'Archive::Simple',
    lazy     => 1,
    builder  => '_build_package',
    init_arg => undef,
);

sub load {
    my ( $distribution, $version_match, $name ) = @_;
    my %searched;

    $version_match = ref $version_match ? $version_match : [$version_match];

    # find all distribution available
    if ( !$distributions{$distribution} ) {
        for my $dir (@INC) {
            next if !-d $dir;
            next if $searched{$dir}++;

            my @packages = glob("$dir/$distribution-*.pla");
            next if !@packages;

            for my $package_version (@packages) {
                my ($version) = $package_version =~ /^$dir\/$distribution-([\d._]+).pla/;
                next if !$version;

                next if $distributions{$distribution}{$version};
                $distributions{$distribution}{$version} = $package_version;
            }
        }
    }

    # find the best matching package version
    my $found_version;
    for my $version ( sort \&_num_sort, keys %{ $distributions{$distribution} } ) {
        if (!$version_match) {
            $found_version = $version;
            last;
        }
        else {
            my $matched;
            # must match all version specifications
            for my $match ( @{ $version_match } ) {
                # TODO need to get better version testing
                my $this = eval "version->new($version) $match";  ## no critic
                if ($this) {
                    $matched = 1;
                }
                else {
                    $matched = 0;
                    last;
                }
            }

            if ( $matched ) {
                # first distribution matched is one to use
                $found_version = $version;
                last;
            }
        }
    }

    if (!$found_version) {
        confess "Could not load distrbution $distribution!\nTry installing it into you \@INC path\n";
    }

    return __PACKAGE__->new(
        file => $distributions{$distribution}{$found_version},
        distribution => $distribution,
        name         => $name,
        version      => $found_version,
    );
}

sub _num_sort {
    no warnings qw/once/; ## no critic

    my $A = $a;
    my $B = $b;

    $A =~ s/(\d+)/sprintf "%09d", $1/egxms;
    $B =~ s/(\d+)/sprintf "%09d", $1/egxms;

    return $A cmp $B;
}

sub _build_package {
    return Archive::Simple->new( name => $_[0]->file );
}

1;

__END__

=head1 NAME

Include::Package - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Include::Package version 0.1.


=head1 SYNOPSIS

   use Include::Package;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION


=head1 SUBROUTINES/METHODS

=head2 load($distribution, $which_versions, $name)


=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut

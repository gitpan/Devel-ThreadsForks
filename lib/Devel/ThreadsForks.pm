package Devel::ThreadsForks;

# set version information
$VERSION= '0.03';

# make sure we do everything by the book from now on
use strict;
use warnings;

# set up the code for use in "do 'threadsforks'"
my $file= 'threadsforks';
my $code= <<'CODE';
#-------------------------------------------------------------------------------
# This file was auto-generated by Devel::ThreadsForks XXXXX on
# YYYYY.

# mark that we've run this (for testing mostly)
$Devel::ThreadsForks::SIZE= SSSSS;

# get configuration information
require Config;
Config->import;

# no ithreads and no forks
if ( !$Config{useithreads} and !eval { require forks; 1 } ) {
    print STDERR <<"TEXT";

************************************************************************
* This distribution requires a version of Perl that has threads enabled
* or which has the forks.pm module installed.  Unfortunately, this does
* not appear to be the case for $^X.
* 
* Please install a threaded version of Perl, or the "forks" module
* before trying to install this distribution again.
************************************************************************

TEXT

    # byebye
    exit 1;
}

# no need to do anything else
1;
CODE

# set version info in generated file
{
    no strict;
    $code =~ s#XXXXX#$VERSION#s;
    $code =~ s#YYYYY# scalar localtime #se;
    $code =~ s#SSSSS# sprintf( '%5d', length $code ) #se;
}

# satisfy -require-
1;

#-------------------------------------------------------------------------------
#
# Standard Perl features
#
#-------------------------------------------------------------------------------
#  IN: 1 class (ignored)

sub import {

    # need to adapt code in $0
    if ( !-e $file ) {

        # get running script
        open( IN, $0 )
          or die "Could not open script for reading '$0': $!";
        my $script= do { local $/; <IN> };
        close IN;

        # update the script
        if ( $script =~
          s#(BEGIN\s*\{\s*eval\s*"\s*use\s+Devel::ThreadsForks\s*)"\s*\s*\}#$1; 1" || do '$file' }#s ) {

            # adapt script
            print STDERR "Installing 'threadsforks' checking logic for $0\n";
            open( OUT, ">$0" )
              or die "Could not open script for writing '$0': $!";
            print OUT $script;
            close OUT
              or die qq{Problem flushing "$0": $!\n};

            # write out check file
            open( OUT, ">$file" )
              or die "Could not open '$file' for writing: $!";
            print OUT $code;
            close OUT
              or die qq{Problem flushing "$file": $!\n};

            # update the manifest(s)
            foreach my $manifest ( glob( "MANIFEST*" ) ) {
                open( OUT, ">>$manifest" ) or die "Could not open '$manifest': $!";
                print OUT "$file                threads/forks test (added by Devel::ThreadsForks)\n";
                close OUT;
            }

            # cannot continue to execute $0, so we do it from here and then exit
            `$^X $0`;
            exit $? >> 8; # propagate the exit value
        }

        # huh?
        print STDERR __PACKAGE__ . " could not find code snippet, aborting\n";
        exit;
    }

    # new version of checking file
    elsif ( -s $file != length $code ) {
        print STDERR "Updating 'threadsforks' checking logic\n";
        open( OUT, ">$file" )
          or die "Could not open '$file' for writing: $!";
        print OUT $code;
        close OUT
          or die qq{Problem flushing "$file": $!\n};
    }

    # do the check
    do $file;
} #import

#-------------------------------------------------------------------------------

__END__

=head1 NAME

Devel::ThreadsForks - check for availability of threads or forks

=head1 VERSION

This documentation describes version 0.03.

=head1 SYNOPSIS

 # before
 BEGIN { eval "use Devel::ThreadsForks" }

 # after
 BEGIN { eval "use Devel::ThreadsForks" || do "threadsforks" }
 # "threadsforks" written and added to MANIFEST

=head1 DESCRIPTION

The Devel::ThreadsForks module only serves a purpose in the development
environment of an author of a CPAN distribution (or more precisely: a user
of the L<ExtUtils::MakeMaker> module).  It only needs to be installed on the
development environment of an author of a CPAN distribution.

There are basically three situations in which this module can get called.

=head2 INITIAL RUN BY DEVELOPER

If the developer has Devel::ThreadsForks installed, and adds the line:

 BEGIN { eval "use Devel::ThreadsForks" }

at the start of the Makefile.PL, then running the Makefile.PL will create a
file called "threadsforks" in the current directory.  This file is intended
to be called with a C<do>.  It performs the actual check whether the
L<threads> can run, or whether the L<forks> module has been installed in
case it is running on an unthreaded Perl.

It will also adapt the code in the Makefile.PL itself by changing it to:

 BEGIN { eval "use Devel::ThreadsForks" || do "threadsforks" }

Finally, it will adapt the MANIFEST by adding the line:

 threadsforks                threads/forks test (Added by Devel::ThreadsForks)

This will cause the check file to be included in any distribution made for
that Makefile.PL.

=head2 LATER RUNS BY DEVELOPER

Any subsequent loading of this module, will just execute the "threadsforks"
file and not do anything else.

=head3 INSTALLATION BY USER

A user trying to install the distribution, will most likely B<not> have the
Devel::ThreadsForks module installed.  This is ok, because then the eval in:

 BEGIN { eval "use Devel::ThreadsForks" || do "threadsforks" }

will fail, and the "threadsforks" file will get executed.  And thus perform
the test in the user environment.  And fail with a message if the version of
Perl is not thread-enabled, or does not have the L<forks> module installed.

=head1 REQUIRED MODULES

 (none)

=head1 AUTHOR

Elizabeth Mattijsen, <liz@dijkmat.nl>.

=head1 COPYRIGHT

Copyright (c) 2012 Elizabeth Mattijsen <liz@dijkmat.nl>.  All rights reserved.
This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

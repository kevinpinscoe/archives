#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(strftime);

# filedates by Robert 'Garfield' Hofer <hofer@informatik.uni-muenchen.de>
# usage: filedates <file's>
# This script prints the access, modified and created time for each file

if (!@ARGV) {
    warn("usage: $0 <files>  -- print the access, modification and creation time\n");
    exit(1);
}

while (my $File = shift @ARGV) {
    my @DAT = stat($File);
    if (!@DAT) {
        warn("stat failed for $File: $!\n");
        next;
    }

    $DAT[8]  = DateStr($DAT[8]);   # atime
    $DAT[9]  = DateStr($DAT[9]);   # mtime
    $DAT[10] = DateStr($DAT[10]);  # ctime (metadata change time on Linux)

    printf("%-17s A[%s] M[%s] C[%s]\n", $File, @DAT[8,9,10]);
}

sub DateStr {
    my ($Time) = @_;
    # Same format you were aiming for, but with 4-digit year
    return strftime("%H:%M:%S %d.%m.%Y", localtime($Time));
}


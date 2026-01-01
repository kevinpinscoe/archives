#!/usr/bin/perl

# filedates by Robert 'Garfield' Hofer <hofer@informatik.uni-muenchen.de>
# usage: filedates <file's>
# This script prints the access, modified and created time for each file

require('ctime.pl');

if (!@ARGV) {
        warn("usage: $0 <files>  -- print the access, modification and creation time\n");
        exit(1);
}

while ($File = shift(@ARGV)) {
        @DAT = stat($File);
        $DAT[8] = &DateStr($DAT[8]);
        $DAT[9] = &DateStr($DAT[9]);
        $DAT[10] = &DateStr($DAT[10]);

        print(sprintf("%-17s A[%s] M[%s] C[%s]\n", $File, @DAT[8,9,10]));
}

sub DateStr {
        local($Time) = @_[0];

        ($Hour, $Min, $Sec, $MDay, $Mon, $Year) = (localtime($Time))[2,1,0,3,4,5];
        $Mon++;
        foreach $Var ('Hour', 'Min', 'Sec', 'MDay', 'Mon') {
                eval("\$$Var = \$$Var > 9 ? \$$Var : '0'.\$$Var");
        }
        return(sprintf("%s:%s:%s %s.%s.%s", $Hour, $Min, $Sec, $MDay, $Mon, $Year));
}

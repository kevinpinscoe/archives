#!/usr/bin/perl

require('ctime.pl');

{

	$File = shift(@ARGV);
        @DAT = stat($File);
        $DAT[9] = &ctime($DAT[9]);

        print(sprintf("%s", @DAT[9]));
}

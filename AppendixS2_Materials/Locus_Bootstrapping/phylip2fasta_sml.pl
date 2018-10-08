#!/usr/bin/perl

# Converts an aligned fasta (aa or dna) seq file to phylip format

# Copyright 2013, Naoki Takebayashi <ntakebayashi@alaska.edu>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Version: 20130612

my $usage = "Usage: $0 [-h] [-v] [infile]\n" .
            "  -h  help\n" .
            "  -v  verbose (print name conversion in STDERR)\n" .
            " infile should be a phylip or paml format (one liner), " .
            "STDIN is used if no infile is given\n";

use IO::File;
use Getopt::Std;
getopts('hv') || die "$usage\n";

die "$usage\n" if (defined ($opt_h));

my $totNumChar = 25;  # number of characters allowed for name in phylip
my $numFrontChar = 25; # When the name is too long, this amount of characters
                      # are used from the beginning of the name, and the rest
                      # are from the end of the name.

while(<>){

    next if ($. == 1);  # skip the first line

    chomp;
    s/^\s+//; s/\s$//;
    next if (/^$/);

    my @line = split (/\s+/);

    my @nameChar = split (//, $line[0]);

    if (@nameChar > $totNumChar) {
        if ( /^(.{$totNumChar})/ ) {
            $name = $1;
        }
    } else {
        $name = $line[0];
    }

    s/$name//;
    s/^\s+//;

    print ">$name\n$_\n";
}

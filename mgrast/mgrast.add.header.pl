#!/usr/bin/env perl
###############################################################################
#
#    mgrast.add.header.pl
#
#	 Adds annotated header to protein file
#    
#    Copyright (C) 2014 Mads Albertsen
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

#pragmas
use strict;
use warnings;

#core Perl modules
use Getopt::Long;

#locally-written modules
BEGIN {
    select(STDERR);
    $| = 1;
    select(STDOUT);
    $| = 1;
}

# get input params
my $global_options = checkParams();

my $inProtein;
my $inHeader;
my $outputfile;

$inProtein = &overrideDefault("protein.faa",'inProtein');
$inHeader = &overrideDefault("header.txt",'inHeader');
$outputfile = &overrideDefault("outputfile.faa",'outputfile');
 
my %header;
 
######################################################################
# CODE HERE
######################################################################

open(INH, $inHeader) or die;

while (my $line = <INH>)  {
	chomp $line;
	my @splitline = split(" ", $line);
	$header{$splitline[0]} = $line;
}

close INH;

open(INP, $inProtein) or die;
open(OUT, ">$outputfile") or die;

while (my $line = <INP>)  {
	chomp $line;
	if ($line =~ m/>/) {
		$line = $header{$line};
	}
	print OUT "$line\n";
}

close INP;
close OUT;
exit;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inHeader|h:s", "inProtein|p:s", "outputfile|o:s");
    my %options;

    # Add any other command line options, and the code to handle them
    # 
    GetOptions( \%options, @standard_options );
    
	#if no arguments supplied print the usage and exit
    #
    exec("pod2usage $0") if (0 == (keys (%options) ));

    # If the -help option is set, print the usage and exit
    #
    exec("pod2usage $0") if $options{'help'};

    # Compulsosy items
    #if(!exists $options{'infile'} ) { print "**ERROR: $0 : \n"; exec("pod2usage $0"); }

    return \%options;
}

sub overrideDefault
{
    #-----
    # Set and override default values for parameters
    #
    my ($default_value, $option_name) = @_;
    if(exists $global_options->{$option_name}) 
    {
        return $global_options->{$option_name};
    }
    return $default_value;
}

__DATA__

=head1 NAME

    calc.gc.pl

=head1 COPYRIGHT

   copyright (C) 2012 Mads Albertsen

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 DESCRIPTION

	Calculates gc content in fastafiles.

=head1 SYNOPSIS

script.pl  -i -o [-h]

 [-help -h]           Displays this basic usage information
 [-inProtein -p]      Input protein file. 
 [-inHeader -h]       Input Header file.
 [-outputfile -o]     Outputfile.
 
=cut
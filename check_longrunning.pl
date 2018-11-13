#!/usr/bin/env perl
#=========================================================================================#
# check_longrunning.pl - Check the list of controllers specified as parameters for        #
#                        long running jobs such as rebuilds and initialization.           #
#-----------------------------------------------------------------------------------------#
# Chad Kerner, Senior System Engineer                                ckerner@illinois.edu #
# Storage Enabling Technologies                                     chad.kerner@gmail.com #
# National Center for Supercomputing Applications                                         #
#-----------------------------------------------------------------------------------------#
# This script calls another shell script we have to post messages to a specific slack     #
# channel so people can get notifications.                                                #
#=========================================================================================#

$debug = 0;
foreach $arg ( @ARGV ) {
   if( $arg eq "--debug" ) { $debug = 1; }
   else                    { push @controllers, $arg; }
}

foreach $controller( @controllers ) {
    $c1 = $controller . '-1';
    $c2 = $controller . '-2';
    $cmd = "/usr/bin/SMcli $c1 $c2 -c \"show storagearray longrunningoperations\;\" ";
    $found = 0;
    open(INCMD, "$cmd |") || die("Unable to execute: $cmd : $!");
    INREC: while(<INCMD>) {
       if( $debug ) { print $_; }
       chomp;
       s/\s+$//g;
       s/^\s+//g;
       next INREC if m/^$/;

       if( m/LOGICAL DEVICES/ ) {
           $found = 1;
       }
       if( m/Script execution complete/ ) {
           $found = 0;
       }
       if( $found == 1 ) {
           $msg = "$controller  $_\n";
           `/usr/local/bin/slack \"$msg\"`;
       }
    }
    close(INCMD);
}


#!/usr/bin/env perl

$debug = 0;
foreach $arg ( @ARGV ) {
   if( $arg eq "--debug" ) { $debug = 1; }
   else                    { push @controllers, $arg; }
}

$my_msg = '';

foreach $controller( sort(@controllers) ) {
    $found = 0;
    $c1 = $controller . '-1';
    $c2 = $controller . '-2';
    $cmd = "/usr/bin/SMcli $c1 $c2 -c \"show storagearray longrunningoperations\;\" ";
    if( $debug ) { print "Executing: $cmd\n"; }
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
           $my_msg = "$controller  $_\n";
           `/usr/local/bin/slack \"$my_msg\"`; 
           $my_msg = '';
       }
    }
    close(INCMD);
}


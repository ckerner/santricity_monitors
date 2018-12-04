#!/usr/bin/env perl

#
#  SMcli md3201-1 md3201-2 -c "set storagearray time;"
#
#  ./settime md3 md4 md3201
#
$debug = 0;
foreach $arg ( @ARGV ) {
   if( $arg eq "--debug" ) { $debug = 1; }
   else                    { push @controllers, $arg; }
}

foreach $controller( @controllers ) {
    $c1 = $controller . '-1';
    $c2 = $controller . '-2';
    $cmd = "/usr/bin/SMcli $c1 $c2 -c \"set storagearray time\;\" ";
    $found = 0;
    open(INCMD, "$cmd |") || die("Unable to execute: $cmd : $!");
    INREC: while(<INCMD>) {
       if( $debug ) { print $_; }
       chomp;
       s/\s+$//g;
       s/^\s+//g;
       next INREC if m/^$/;

    }
    close(INCMD);
}


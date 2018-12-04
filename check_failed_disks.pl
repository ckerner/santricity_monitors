#!/usr/bin/env perl

$debug = 0;
$verbose = 0;
foreach $arg ( @ARGV ) {
   if( $arg eq "--debug" ) { $debug = 1; }
   elsif( $arg eq "--verbose" ) { $verbose = 1; }
   else                    { push @controllers, $arg; }
}

foreach $controller( @controllers ) {
    $c1 = $controller . '-1';
    $c2 = $controller . '-2';
    $cmd = "/usr/bin/SMcli $c1 $c2 -c \"show storageArray healthStatus\;\" ";
    $found = 0;
    $prt = 0;

    if( $debug || $verbose ) { print "Executing: $cmd\n"; }
    open(INCMD, "$cmd |") || die("Unable to execute: $cmd : $!");
    INREC: while(<INCMD>) {
       if( $debug ) { print $_; }
       chomp;
       s/\s+$//g;
       s/^\s+//g;
       next INREC if m/^$/;

       if( m/Impending Physical/ ) { $found = 1; $my_msg = 'Impending Failure'; }
       elsif( m/Degraded Virtual Disk/ ) { $found = 1; $my_msg = 'Degraded Virtual Disk'; }
       elsif( m/Failed physical disk/ ) { $found = 2; $my_msg = 'Failed Drive'; }

       if( $found == 1 ) {
           if( m/Storage array: (.*)/ ) { $my_array = $1; }
           if( m/Disk group: (.*)/ )    { $my_group = $1; }
           if( m/RAID level: (.*)/ )    { $my_level = $1; }
           if( m/Enclosure: (.*)/ )     { $my_enc = $1; }
           if( m/.*disk slot.*: (.*)/ ) { $my_slot = $1; }
           if( m/Virtual Disks: (.*)/ ) { $my_dsk = $1; $prt = 1; }
       }

       if( m/Script execution complete/ ) {
           $found = 0;
       }
       if( $found == 1 && $prt == 1 ) {
           $msg = "$my_msg: Controller: $my_array   $my_enc, Slot $my_slot   Disk_Group: $my_group  ";
           $msg .= "RAID: $my_level  Virtual_Disks: $my_dsk";

           $msg =~ s/Expansion enclosure/Enclosure/g;
           $msg =~ s/RAID enclosure/Enclosure/g;

           if( ! $debug ) { `/usr/local/bin/slack \"$msg\"`; }
           if( $debug )   { print "$msg\n"; }
           if( $verbose ) { print "$msg\n"; }
           $found = 0;
           $prt = 0;
           $my_msg = '';
       }
    }
    close(INCMD);
}


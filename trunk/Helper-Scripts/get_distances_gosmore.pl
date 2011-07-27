#!/usr/local/bin/perl -w

use strict;
use warnings;
use Math::Trig;

#inputs in degrees
sub Haversine {
  my ($lat1, $long1, $lat2, $long2) = @_;
  my $r=6367;

  my $dlong = deg2rad($long1) - deg2rad($long2);
  my $dlat  = deg2rad($lat1) - deg2rad($lat2);

  my $a = sin($dlat/2)**2 +cos(deg2rad($lat1)) 
      * cos(deg2rad($lat2))
      * sin($dlong/2)**2;
  my $c = 2 * (asin(sqrt($a)));
  my $dist = $r * $c;
  return $dist;
}

my @rows = <>;

chop(@rows);

for(my $i=0; $i < @rows; $i++) {
  for(my $j=0; $j < @rows; $j++) {
    #next if($i == $j);

    $rows[$i] =~ /(\d+),([0-9.]+),([0-9.]+),/;
    my($id1) = $1;
    my($lat1) = $2;
    my($lon1) = $3;
    $rows[$j] =~ /(\d+),([0-9.]+),([0-9.]+),/;
    my($id2) = $1;
    my($lat2) = $2;
    my($lon2) = $3;

    my $shortest_distance;
    my $cycle_distance = 9999;
    my $foot_distance = 9999;

    unlink <short*>;
    #print("QUERY_STRING=\"flat=$lat1&flon=$lon1&tlat=$lat2&tlon=$lon2&fast=1&v=foot\" && export QUERY_STRING && cd gosmore && ./gosmore > ../shortest.txt");
    #print("\n");
    system("QUERY_STRING=\"flat=$lat1&flon=$lon1&tlat=$lat2&tlon=$lon2&fast=1&v=foot\" && export QUERY_STRING && cd gosmore && ./gosmore > ../shortest.txt");
    if(open(SHORTEST, "<shortest.txt")) {
      my $prev_lat = $lat1;
      my $prev_lon = $lon1;
      $foot_distance = 0;
      while(<SHORTEST>) {
        $_ = substr $_,1;
        my($lat, $lon) = split /,/;
        if(!$lat || !$lon) {
          #print "DEBUG: Ignoring $_\n";
          next;
        }
        #print "DEBUG: $lat,$lon,$foot_distance\n";
        $foot_distance += Haversine($prev_lat,$prev_lon,$lat,$lon);
        $prev_lat = $lat;
        $prev_lon = $lon;
      }
      $foot_distance += Haversine($prev_lat,$prev_lon,$lat2,$lon2);
    }

    unlink <short*>;
    #print("QUERY_STRING=\"flat=$lat1&flon=$lon1&tlat=$lat2&tlon=$lon2&fast=1&v=cycle\" && export QUERY_STRING && cd gosmore && ./gosmore > ../shortest.txt");
    #print("\n");
    system("QUERY_STRING=\"flat=$lat1&flon=$lon1&tlat=$lat2&tlon=$lon2&fast=1&v=cycle\" && export QUERY_STRING && cd gosmore && ./gosmore > ../shortest.txt");
    if(open(SHORTEST, "<shortest.txt")) {
      my $prev_lat = $lat1;
      my $prev_lon = $lon1;
      $cycle_distance = 0;
      while(<SHORTEST>) {
        $_ = substr $_,1;
        my($lat, $lon) = split /,/;
        if(!$lat || !$lon) {
          #print "DEBUG: Ignoring $_\n";
          next;
        }
        #print "DEBUG: $lat,$lon,$cycle_distance\n";
        $cycle_distance += Haversine($prev_lat,$prev_lon,$lat,$lon);
        $prev_lat = $lat;
        $prev_lon = $lon;
      }
      $cycle_distance += Haversine($prev_lat,$prev_lon,$lat2,$lon2);
    }
    unlink <short*>;
    if($cycle_distance == $foot_distance) {
      print("$id1,$id2,$cycle_distance,tie,$cycle_distance,$foot_distance\n");
    } elsif($foot_distance < $cycle_distance) {
      print("$id1,$id2,$foot_distance,foot,$cycle_distance,$foot_distance\n");
    } else {
      print("$id1,$id2,$cycle_distance,bicycle,$cycle_distance,$foot_distance\n");
    }
  }
}

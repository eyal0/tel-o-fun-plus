#!/usr/local/bin/perl -w

use strict;
use warnings;

open(STATIONS, "< telofun_stations_fixed.csv");
my %stations;

while(<STATIONS>) {
  my @station_info = split /,/;
  $stations{$station_info[0]} = [@station_info[1..@station_info-1]];
}

while(<>) {
  chop;
  if(/9999,tie/) {
    my @failed_pair = split /,/;
    print "$failed_pair[0],$failed_pair[1] http://maps.google.com/maps?q=from%20$stations{$failed_pair[0]}[0],$stations{$failed_pair[0]}[1]%20to%20$stations{$failed_pair[1]}[0],$stations{$failed_pair[1]}[1]&dirflg=w\n";
  }
}

#!/usr/bin/perl
use IO::File;
use strict;

my $fh;
my $policyName=$ARGV[0];
my $fileName = "/var/opt/OV/tmp/${policyName}.txt";
unless (-f $fileName){
  system('touch',$fileName);
  print "Policy $policyName has been disabled";
} else {
  unlink $fileName;
  print "Policy $policyName has been enabled";
}



#!/opt/OV/nonOV/perl/a/bin/perl
use Getopt::Long;
use strict;
use warnings;
my $mycmd = "";
my $stringToSearch = "";
my $stringToExclude = "";
my $exitCode=1;
my $matchCounter = 0;
my $inverseMode= "";
my $trigger=1;
GetOptions('command=s' => \$mycmd, 'search_string=s' => \$stringToSearch , 'exclude_string=s' => \$stringToExclude,'inverse' => \$inverseMode, 'trigger=s' => \$trigger);
#my $fullCommand = $mycmd.'|grep '. $stringToSearch;
my @output = qx($mycmd);
foreach my $line (@output) {
  if($line =~ /($stringToSearch)/){
	if($line !~ /($stringToExclude)/){
 	   $matchCounter++;
        }
  }
}
if($matchCounter >= $trigger){
	$exitCode=0;
}
if($inverseMode){
  if($exitCode != 0){
	$exitCode =0;
  }else{
	$exitCode=1;
  }
}
exit $exitCode;


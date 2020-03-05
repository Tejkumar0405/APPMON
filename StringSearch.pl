#!/opt/OV/nonOV/perl/a/bin/perl
use Getopt::Long;
use strict;
use warnings;
my $mycmd = "";
my $inverseMode= "";
my $stringToSearch = "";
my $exitCode=1;
GetOptions('command=s' => \$mycmd, 'search_string=s' => \$stringToSearch,'inverse' => \$inverseMode);
my $fullCommand = $mycmd.'|grep '. $stringToSearch;
qx($fullCommand);
if($? == 0 && !$inverseMode){
 $exitCode =0;
}
exit $exitCode;


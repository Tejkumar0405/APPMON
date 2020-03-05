#!/opt/OV/nonOV/perl/a/bin/perl
use Getopt::Long;
use strict;
use warnings;
my $mycmd = "";
my $trigger = "";
my $inverseMode= "";
my $exitCode=1;
GetOptions('command=s' => \$mycmd, 'trigger=s' => \$trigger,'inverse' => \$inverseMode);
my $fullCmd = $mycmd . " 2>&1";
my $output = qx($fullCmd);
my $shellExitCode = $? >> 8;
if($shellExitCode != 0 ){
  exit $shellExitCode;
}
if($output >= $trigger ){
  $exitCode=0;
}else{
  $exitCode=1;
}
if($inverseMode ){
  if($exitCode ==0 ){
     $exitCode =1;
  }else{
     $exitCode=0;
  }
}
exit $exitCode;

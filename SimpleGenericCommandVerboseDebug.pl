#!/opt/OV/nonOV/perl/a/bin/perl
use Getopt::Long;
use strict;
use warnings;
my $mycmd = "";
my $trigger = "";
my $inverseMode= "";
my $exitCode=1;
my $txt ="";
my $PolicyName = $ARGV[0];
my $Object = $ARGV[1];
my $debugCommand="";

GetOptions('command=s' => \$mycmd, 'trigger=s' => \$trigger,'inverse' => \$inverseMode);
my $audit_clob = "Running test with \n Command: $mycmd \n";
my $fullCmd = $mycmd . " 2>&1";
my $output = qx($fullCmd);
my $shellExitCode = $? >> 8;
if($shellExitCode != 0 ){
   $audit_clob = $audit_clob . "Command returned with exit code $shellExitCode \n";
   $exitCode = 999;
}
$txt = "$output";
chomp($txt);
$txt =~ s/ //g;
$audit_clob = $audit_clob . "Command returned :$txt Trigger = $trigger";
if(length($txt) < 1){
        $audit_clob = $audit_clob . " Error - Command output is of invalid length ";
        $exitCode =999;
}
if($exitCode == 999){

}else {
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
}
print $audit_clob;
if($exitCode == 0){
      `/opt/OV/bin/opcmon \"$PolicyName\"=0 -object \"$Object\" -option message=\"$audit_clob\" -option appStatus="$appStatus"`;
}else{
      `/opt/OV/bin/opcmon \"$PolicyName\"=1 -object \"$Object\" -option message=\"$audit_clob\" -option appStatus="$appStatus"`;
}

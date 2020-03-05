#!/opt/OV/nonOV/perl/a/bin/perl
use Getopt::Long;
use strict;
use warnings;
my $mycmd = "";
my $exitCode=1;
my $txt ="";
my $PolicyName = $ARGV[0];
my $Object = "";
my $monitorStatus="ENABLED";
my $appStatus="";
GetOptions('object=s' => \$Object, 'monitor_status=s' => \$monitorStatus, 'command=s' => \$mycmd);
my $audit_clob = "Running test with \n Command: $mycmd \n";
my $file_loc = "/tmp/SimpleGenericCommandMeasurementDebug.txt";
open my $file , '>>', $file_loc or die $!;
my $fullCmd = $mycmd . " 2>&1";
my $output = qx($fullCmd);
my $shellExitCode = $? >> 8;
if($shellExitCode != 0 ){
   $audit_clob = $audit_clob . "Command returned with exit code $shellExitCode \n";
   $exitCode = 999;
}
$txt = "$output";
chomp($txt);
print $file $txt;
$txt =~ s/ //g;
$audit_clob = $audit_clob . "Command returned :$txt ";
if(length($txt) < 1){
        $audit_clob = $audit_clob . " Error - Command output is of invalid length ";
        $exitCode =999;
}
if($exitCode == 999){
 $output = 999999999;
}

my $fileName = "/var/opt/OV/bin/instrumentation/appStatus.txt";
unless (-f $fileName){
   $appStatus="RUN";
} else {
   open(my $fh,'<',$fileName) or die "cannot open file";
   {
     local $/;
     $appStatus =<$fh>;
   }
}
$audit_clob = $audit_clob . "AppStatus =". $appStatus;
chomp $appStatus;
print $file "App sttaus is $appStatus";
print $file $audit_clob;
if($appStatus ne "OFF"){
        if(($monitorStatus ne "DISABLED")  and (($monitorStatus ne "DR_SUPPRESSED" and $appStatus eq "PASSIVE") or ($appStatus ne "PASSIVE"))){

                        `/opt/OV/bin/opcmon $PolicyName=$output -object $Object -option message="$audit_clob" -option appStatus="$appStatus"`;
        }else{
          `/opt/OV/bin/opcmon $PolicyName="9999999" -object $Object -option message=\"$audit_clob\" -option appStatus="$appStatus"`;
        }
}else{
        `/opt/OV/bin/opcmon $PolicyName=9999999 -object $Object -option message=\"$audit_clob\" -option appStatus="$appStatus"`;
}


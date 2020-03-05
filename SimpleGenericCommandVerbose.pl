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
my $Object = "";
my $monitorStatus="ENABLED";
my $appStatus="";
my $debugCommand="";
GetOptions('object=s' => \$Object, 'monitor_status=s' => \$monitorStatus, 'command=s' => \$mycmd, 'trigger=s' => \$trigger,'inverse' => \$inverseMode, 'debug_command=s' => \$debugCommand);
my $audit_clob = "Running test with \n Command: $mycmd \n";
print $audit_clob;
my $fullCmd = $mycmd . " 2>&1";
my $output = qx($fullCmd);
my $shellExitCode = $? >> 8;
if($shellExitCode != 0 ){
   $audit_clob = $audit_clob . "Command returned with exit code $shellExitCode \n";
   $exitCode = 999;
}
$txt = "$output";
chomp($txt);
print $audit_clob;
$txt =~ s/ //g;
$txt =~ s/\n//g;
$txt =~ s/\r//g;
$audit_clob = $audit_clob . "Command returned :$txt Trigger = $trigger \n";
if(length($txt) < 1){
        $audit_clob = $audit_clob . " Error - Command output is of invalid length\n ";
        $exitCode =999;
}
if($exitCode!=999 && $txt =~  /^[0-9]+(\.\d+)?$/){
}else{
        $audit_clob = $audit_clob . " Command returned non numeric output hence failing the test, Please fix the policy \n";
        $exitCode = 999;
}
print $debugCommand;
if(length($debugCommand)>0){
   my $debugCmd = $debugCommand . " 2>&1";
   
   my $debugOutput = qx($debugCmd);
   $audit_clob = $audit_clob . "-----------Debug Output for ". $debugCommand. " ----------------------\n";
   $audit_clob = $audit_clob . $debugOutput;
   $audit_clob = $audit_clob . "\n---------------------------------------------------------------------\n";


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
$audit_clob = $audit_clob . "AppStatus =". $appStatus. "\n";
chomp $appStatus;
print "Going to call opcmon ";
if($appStatus ne "OFF"){
        if(($monitorStatus ne "DISABLED")  and (($monitorStatus ne "DR_SUPPRESSED" and $appStatus eq "PASSIVE") or ($appStatus ne "PASSIVE"))){

                if($exitCode == 0){
                        `/opt/OV/bin/opcmon $PolicyName=0 -object \"$Object\" -option message="$audit_clob" -option appStatus="$appStatus"`;
                }else{
                        `/opt/OV/bin/opcmon \"$PolicyName\"=1 -object \"$Object\" -option message="$audit_clob" -option appStatus="$appStatus"`;
                }
        }else{
		 `/opt/OV/bin/opcmon $PolicyName=9999 -object \"$Object\" -option message="$audit_clob" -option appStatus="$appStatus"`;
	}
}else{
	 `/opt/OV/bin/opcmon $PolicyName=9999 -object \"$Object\" -option message="$audit_clob" -option appStatus="$appStatus"`;
}


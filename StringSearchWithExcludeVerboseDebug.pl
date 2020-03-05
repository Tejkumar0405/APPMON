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
my $PolicyName = $ARGV[0];
my $file_loc = "/tmp/StringSearchWithExcludeVerboseDebug.txt";
open my $file , '>>', $file_loc or die $!;
my $Object = "";
my $monitorStatus = "";
my $appStatus = "";

GetOptions('object=s' => \$Object, 'monitor_status=s' => \$monitorStatus, 'command=s' => \$mycmd, 'search_string=s' => \$stringToSearch , 'exclude_string=s' => \$stringToExclude,'inverse' => \$inverseMode, 'trigger=s' => \$trigger);
my $audit_clob = "Running test with \n Command: $mycmd \n SearchString: $stringToSearch \n";
#my $fullCommand = $mycmd.'|grep '. $stringToSearch;
my @output = qx($mycmd);
print $file " Starting Logging "; 
my $outputString = join("\n",@output);
$audit_clob = $audit_clob . "Output from command is \n $outputString \n";

foreach my $line (@output) {
  if($line =~ /($stringToSearch)/){
        if($line !~ /($stringToExclude)/){
           $matchCounter++;
        }
  }
}
if(length($audit_clob) > 45000){
 $audit_clob=substr($audit_clob,0,45000);
}
$audit_clob=$audit_clob . "\n-------------------------------------------\n";
$audit_clob = $audit_clob . "Match = $matchCounter   Trigger = $trigger";
$audit_clob=$audit_clob . "\n-------------------------------------------\n";

print $file $audit_clob;
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

print $file "Exit code is $exitCode Policy is $PolicyName  Object is $Object\n" ;
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
if($appStatus ne "OFF"){
        if(($monitorStatus ne "DISABLED")  and (($monitorStatus ne "DR_SUPPRESSED" and $appStatus eq "PASSIVE") or ($appStatus ne "PASSIVE"))){

                if($exitCode == 0){
                        print $file "Sending pass message";
                        `/opt/OV/bin/opcmon $PolicyName=0 -object $Object -option message="$audit_clob" -option appStatus="$appStatus"`;
                }else{
                        `/opt/OV/bin/opcmon $PolicyName=1 -object $Object -option message="$audit_clob" -option appStatus="$appStatus"`;
                }
        }else{
		`/opt/OV/bin/opcmon $PolicyName=9999999 -object \"$Object\" -option message="$audit_clob" -option appStatus="$appStatus"`;
        }
}else{
	 `/opt/OV/bin/opcmon $PolicyName=9999999 -object \"$Object\" -option message="$audit_clob" -option appStatus="$appStatus"`;
}


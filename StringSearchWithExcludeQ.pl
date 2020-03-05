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
my $Object = "";
my $appStatus = "";
my $monitorStatus = "";
my $suppressMatchedLines="";
my $debugEnabled="";
my $suppressOutput="";
my $file_loc = "/var/opt/OV/log/${PolicyName}.txt";
open my $file , '>>', $file_loc or die $!;

GetOptions('object=s' => \$Object,'monitor_status=s' => \$monitorStatus,'command=s' => \$mycmd, 'search_string=s' => \$stringToSearch , 'exclude_string=s' => \$stringToExclude,'inverse' => \$inverseMode, 'trigger=s' => \$trigger,'suppress_matchedoutput' => \$suppressMatchedLines,'debug_enabled' => \$debugEnabled,'suppress_output' => \$suppressOutput);
my $audit_clob = "Running test with \n Command: $mycmd \n SearchString: $stringToSearch \n";
#my $fullCommand = $mycmd.'|grep '. $stringToSearch;
my @output = qx($mycmd);
my $outputString = join("\n",@output);

foreach my $line (@output) {
  if($line =~ /($stringToSearch)/){
        if($line !~ /($stringToExclude)/){
           if($suppressMatchedLines){
           }else{
           $audit_clob = $audit_clob . "Matched line is :" . $line ."\n";         
           }
           $matchCounter++;
        }
  }
}
if(!$suppressOutput){
$audit_clob = $audit_clob . "Output from command is \n $outputString \n";
}
if(length($audit_clob) > 45000){
 $audit_clob=substr($audit_clob,0,45000);
}
$audit_clob=$audit_clob . "\n-------------------------------------------\n";
$audit_clob = $audit_clob . "Match = $matchCounter   Trigger = $trigger";
$audit_clob=$audit_clob . "\n-------------------------------------------\n";

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
if($debugEnabled){
   print $file "Run started at ". (localtime),"\n";
   print $file $audit_clob."\n";
   print $file "Exit code is ".$exitCode;
  
}
$audit_clob = $audit_clob . "AppStatus =". $appStatus;
chomp $appStatus;
$audit_clob =~ s/"//g ;
if($appStatus ne "OFF"){
        if(($monitorStatus ne "DISABLED")  and (($monitorStatus ne "DR_SUPPRESSED" and $appStatus eq "PASSIVE") or ($appStatus ne "PASSIVE"))){

                if($exitCode == 0){
                        `/opt/OV/bin/opcmon \"$PolicyName\"=0 -object \"$Object\" -option message="$audit_clob" -option appStatus="$appStatus"`;
                }else{
                        `/opt/OV/bin/opcmon \"$PolicyName\"=1 -object \"$Object\" -option message="$audit_clob" -option appStatus="$appStatus"`;
                }
        }else{
              `/opt/OV/bin/opcmon \"$PolicyName\"=9999 -object \"$Object\" -option message="$audit_clob" -option appStatus="$appStatus"`;
        }
}else{
 	`/opt/OV/bin/opcmon \"$PolicyName\"=9999 -object \"$Object\" -option message="$audit_clob" -option appStatus="$appStatus"`;
}





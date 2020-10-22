#!/usr/bin/env perl

print "values={}\n";
print "ar={'true','false'};\n";

open my $info, $ARGV[0] or die "Could not open $file: $!";
my $ses_md5=substr($ARGV[0],9,65);

while( my $line =<$info>){
	$str=substr($line,3,length($line)-7);
	my @array1=split("\" , \"",$str);
	my @array2=split("\t",$array1[2]);
	my $md5p=$array1[0];
	my $md5s=$array1[1];
	my $ses_md5_path=$ses_md5;
	$ses_md5_path =~ s/_/\//g;
	my $filename="generate/".$md5p."_".$md5s;
	foreach $kval (keys(@array2)){
		my $var = $array2[$kval];
		if ( $var =~ /gen/ ){
			my $gen=substr($var,index($var,"_")+1);
			my $col=substr($gen,index($gen,"_")+1);
			my $currentfilename="fix/".$md5p."_".$md5s."_".$col;
			$currentfilename=$filename."_".$col unless (-e $currentfilename);
			# if there is a fix file, lets use it!!! 
			print "values['$gen']=";
			open (FILE, '<', $currentfilename );
			print <FILE>;
			close (FILE);
			#print "values['$gen']=fun_".$md5p."_".$md5s."_".$col."()\n";
		}
	}
}
print "return values";

#!/usr/bin/env perl

use File::Basename;

open my $info, $ARGV[0] or die "Could not open $file: $!";
my $ses_md5=substr($ARGV[0],5,32);
my $dir=dirname($ARGV[0]);
my $row=1;
my %var_list;
while( my $line =<$info>){
	# we read the file and process line by line
	my $offset=index($line,"\" , \"",index($line,"\" , \"")+3)+5;
	my $md5=substr($line,3,32);
	my $smd5=substr($line,40,32);
	print(substr($line,0,$offset));
	my @str =split("\t",substr($line,$offset,length($line)-$offset-4));
	my $len=scalar @str;
	my $col=1;
	foreach $kval (keys(@str)){
		my $word=$str[$kval];
		my $filename="generate/".$md5."_".$smd5."_".$col;
		open(my $fhquery, '<', $filename) or die "Could not open $filename: $!";
		my $tline=readline($fhquery);
		$tline=readline($fhquery);
		close($fhquery);
		my ($comment, $type, $rest)=split(" ",$tline);		
		#		print $type;
		$word.=$type;
		if ( exists($var_list{$word} ) ) {
			print("var_". $var_list{$word});
		}else{
			$var_list{$word}=$row."_".$col;
			print("gen_". $var_list{$word});
		}
		if ($len > 1) { print("\t");}
		$len--;
		$col++;
	}
	$row++;
	print (substr($line,length($line)-4));
}

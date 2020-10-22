#!/usr/bin/env perl

use List::MoreUtils ':all';
use File::Basename;
use Statistics::Normality ':all';
use Syntax::Keyword::Try;

foreach (@ARGV){
        $filename=$_;

        my $function_name=basename($filename);
	my $qandd_template=basename($filename,"_value");
        my $dirname=dirname($filename);
        my $newfilename="generate/".$qandd_template;

        open(my $newfile, '>',$newfilename) or die "$newfilename";
	#        print $newfile "function fun_".$qandd_template."()\n";

	open my $info, '<', $filename or die "The file could not be open: $filename";
	my $distribution="uniform";
	my $minval=0;
	my $maxval=0;
	my $minlen=0;
	my $maxlen=0;
	my $before="";
	my $sum=0;
	my $count=0;
	my $lastval="";
	my $uniq=1;
	while (my $line =<$info>){
	        $str=substr($line,0,length($line)-1);
		$lastval=$str if ($lastval eq "");
		$uniq=0 if ( $uniq == 0 || $lastval ne $str );
		#print $uniq;
                $maxlen=length $str if (length $str > $maxlen );
		if ( ($before eq "%b" || $before eq "")  && ($str =~ /^true$/i || $str =~ /^false$/i ) ){
			$before="%b";
		}else{
	        if ( ($before eq "%d" || $before eq "")  && $str =~ /^[0-9]+$/) {
	                $before="%d";
	                $minval=$str if ($str < $minval || $minval == 0 );
	                $maxval=$str if ($str > $maxval );
			$sum+=$str;
	        }else{
	                $minlen=length $str if (length $str < $minval || $minlen == 0 );
		        if ( ($before eq "%u" || $before eq "") && $str =~ /^[0-9a-f]+$/i) {
		                $before="%u";
		        }else{if ( ( $before eq "%s" || $before eq "%u" || $before eq "") && $str =~ /^[a-z]+$/i) {
		                $before="%s";
		        }else{ if ( $str =~ /^[0-9a-z]+$/i) { # this might not be needed, as the only alternative is it
		                $before="%a";
		        }}}
		}}
	        $count++;
	}
	
	if ($uniq == 1){
		print $newfile "'$str';\n";
		if ( $before eq "%d" ){
			$before="%c %d $minval $maxval";
		}else{
			$before="%c $before $minlen $maxlen";
		}
	}else{ if ( $before eq "%d" ) {
		seek $info, 0, 0;
		my $sumsq=0;
		my $media=int($sum / $count);
		my @stest;
		while (my $line =<$info>){ 
			$str=substr($line,0,length($line)-1);
			#$sumsq+= ($str - $media) * ($str - $media);
			push(@stest,$str);
		}
	
		my $pval= 0 ;
		try {$pval = shapiro_wilk_test([@stest]);}
		catch { print "Warning: not using Normal test\n";}
		#		print $pval;
		#my $var=sqrt($sumsqr / $count);
		if ($pval > 0.05 ){
			my $diff=($maxval - $minval) /2;
			my $min=int($media - $diff);
			$min=0 if ($minval >= 0 && $min < 0 );
			my $max=int($media + $diff);
			print $newfile "sysbench.rand.gaussian( ". $min  .",". $max .") ;\n";
			$before="%g$media $min $max";
		}else{
		        print $newfile "sysbench.rand.".$distribution."(".$minval.",".$maxval .");\n";
			$before="%n$maxlen"."_$maxval $minval $maxval";
		}
        }else{ if ( $before eq "%b" ) {
                print $newfile "ar[sysbench.rand.uniform(1,2)];\n";
        }else{ if ( $before eq "%u" ) {
	        print $newfile "sysbench.rand.hexadecimal(".$minlen.", ".$maxlen.");\n";
	}else{ if ( $before eq "%s" ) {
	        print $newfile "sysbench.rand.string(string.rep(\"@\", sysbench.rand.uniform(".$minlen.", ".$maxlen.")));\n";
	}else{ if ( $before eq "%a" ) {
	        print $newfile "string.gsub(sysbench.rand.varstring(".$minlen.", ".$maxlen."),'\\\\','d');\n";
	}}}}
		$before.=" $minlen $maxle"
	}}

	print $newfile "-- $before\n";

	close($info);
	#        print $newfile "end\n";
}

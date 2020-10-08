#!/usr/bin/env perl

use List::MoreUtils ':all';
use File::Basename;

foreach (@ARGV){
        $filename=$_;

        my $function_name=basename($filename);
        my $qandd_template=basename($filename,"_value");
        my $dirname=dirname($filename);
        my $newfilename=$dirname."/".$qandd_template."_generate";

        open(my $newfile, '>',$newfilename) or die "$newfilename";
        print $newfile "function fun_".$qandd_template."()\n";

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
		print $uniq;
	        if ( ($before eq "%d" || $before eq "")  && $str =~ /^[0-9]+$/) {
	                $before="%d";
	                $minval=$str if ($str < $minval || $minval == 0 );
	                $maxval=$str if ($str > $maxval );
			$sum+=$str;
	        }else{
	                $minlen=length $str if (length $str < $minval || $minlen == 0 );
	                $maxlen=length $str if (length $str > $maxlen );
	        if ( ($before eq "%u" || $before eq "") && $str =~ /^[0-9a-f]+$/i) {
	                $before="%u";
	        }else{if ( ( $before eq "%s" || $before eq "%u" || $before eq "") && $str =~ /^[a-z]+$/i) {
	                $before="%s";
	        }else{ if ( $str =~ /^[0-9a-z]+$/i) { # this might not be needed, as the only alternative is it
	                $before="%a";
	        }}}}
	        $count++;
	}
	
	if ($uniq == 1){
		print $newfile "return '$str';\n";
	}else{ if ( $before eq "%d" ) {
		seek $info, 0, 0;
		my $sumsq=0;
		my $media=$sum / $count;
		while (my $line =<$info>){ 
			$str=substr($_,0,length($line)-1);
			$sumsq+= ($str - $media) * ($str - $media);
		}
		my $var=sqrt($sumsqr / $count);
		if ($var <=3 ){
			my $min=$media - $var * $var;
			my $max=$media + $var * $var;
			print $newfile "return sysbench.rand.gaussian( ". $min  .",". $max .") ;\n";
		}else{
		        print $newfile "return sysbench.rand.".$distribution."(".$minval.",".$maxval .");\n";
		}
	}else{ if ( $before eq "%u" ) {
	        print $newfile "return sysbench.rand.hexadecimal(".$minlen.", ".$maxlen.");\n";
	}else{ if ( $before eq "%s" ) {
	        print $newfile "return sysbench.rand.string(string.rep(\"@\", sysbench.rand.uniform(".$minlen.", ".$maxlen.")));\n";
	}else{ if ( $before eq "%a" ) {
	        print $newfile "return string.gsub(sysbench.rand.varstring(".$minlen.", ".$maxlen."),'\\\\','d');\n";
	}}}}}
	
	close($info);
        print $newfile "end\n";
}

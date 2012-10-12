@mas_file = grep($_ =~ m/[^\/?:*"><|]\.txt/i, @ARGV) or die("Enter the parameters"."\n");

$exit_file = pop(@mas_file);

foreach(@mas_file){
	local $/ = "";
	if(open(FILE, "<$_")){
		@file_stat = stat("$_");
		$total_amount += $file_stat[7];
		last if($total_amount > 204800) and print "Total Size exceeds"."\n";
		@symbol2 = grep($_ !~ m/\D/i, @symbol = split(/\s+/, join(" ", @t = <FILE>)));
		for($a = 0; $a < @symbol2; $a++){
				$number[$num] = $symbol2[$a];
				$num++;
		}			
	}
	else{
		print "Error: $!"."\n";
	}
	close(FILE);
}

@number = sort {$a <=> $b} @number;

open(FILE, ">$exit_file") or die("Error: $!");
scalar(@number) == 0 ? print "Buffer is empty file could not be"."\n" : print FILE join(" ", @number);
close(FILE);
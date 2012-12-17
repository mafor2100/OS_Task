@mas_file = grep($_ =~ m/[^\/?:*"><|]\.txt/i, @ARGV) or die("Enter the parameters"."\n");

$exit_file = pop(@mas_file);

foreach(@mas_file){
	local $/ = "";
	if(open(FILE, "<$_")){
		eval('@t = <FILE>;');
		if(length($@)>0){
			print $@;
		}
		else{
			eval('push(@number, @symbol2 = grep($_ !~ m/\D/i, @symbol = split(/\s+/, join(" ", @t))));');
			print $@;
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
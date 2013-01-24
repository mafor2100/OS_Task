@mas_file = grep($_ =~ m/[^\/?:*"><|]\.txt$/i, @ARGV) or die("Enter the correct parameters"."\n");
$exit_file = pop(@mas_file);
open(FILE_OUT, ">$exit_file") or die("Error: $!");
local $/ = "";
foreach(@mas_file){
	eval{
		open(FILE, "<$_");
		@t = <FILE>;
		push(@number, @symbol2 = grep($_ !~ m/\D/i, @symbol = split(/\s+/, join(" ", @t))));
		close(FILE);
	};
	print $@;	
}
eval{
	scalar(@number) == 0 ? print "Buffer is empty file could not be"."\n" : print FILE_OUT join(" ", @number = sort {$a <=> $b} @number);
	};
print $@;	
close(FILE_OUT);
#!/usr/local/bin/perl
use Getopt::Std;
my %opts;
getopts('ce:',\%opts);

print <<EOH;
-----------------------------------------------
H E L P:
 Usage: task_1.pl [-c|-e <error>]
 EXAMPLE: task_1.pl -e 3 (3-number of error)
 -c - Correct job
 -e - Job with error(list of errors look lower)
 
 LIST OF ERRORS:
	'RC'      => 0
	'DC'      => 1
	'ADD'     => 2
	'ADDNEXT' => 3
	'IP'      => 4
	'ALU'     => 5
	'ZAPP'    => 6
	'ZAM2'    => 7
	'ZAM1'    => 8
	'VZAP1'   => 9
-----------------------------------------------
EOH

%comand =
(
	'0' => 'RC',
	'1' => 'DC',
	'2' => 'ADD',
	'3' => 'ADDNEXT',
	'4' => 'IP',
	'5' => 'ALU',
	'6' => 'ZAPP',
	'7' => 'ZAM2',
	'8' => 'ZAM1',
	'9' => 'VZAP1'
);

#Ошибки
%error =
(
	'RC'      => 1,
	'DC'      => 1,
	'ADD'     => 1,
	'ADDNEXT' => 1,
	'IP'      => 1,
	'ALU'     => 1,
	'ZAPP'    => 1,
	'ZAM2'    => 1,
	'ZAM1'    => 1,
	'VZAP1'   => 1
);
if(!%opts){print 'Not argument of comand. Change -c or -e';exit;}
for(keys %opts)
{
	if($opts{'c'}){$comand = 10;print 'Correct job';}
		elsif($opts{'e'} || $opts{'e'} == 0){$comand = $opts{'e'};}
			else{$comand = 10;print 'Correct job';}
}
if($comand != 10)
{
	unless($comand =~ /^[0-9]$/){print "\n\rIncorrect number of error! Look help";}
	else
	{
		$error{$comand{$comand}} = 0;
		print "\n\rError in the $comand{$comand}\n\r-----------------------------------------------";
	}
}

##I
#----Память: считывание и функционал для нее----
sub RAM
{
	@mem = split(//,$_[0]);
	for(0..256)
	{
		if($mem[$_] eq "")
		{
			$mem[$_] = 0;
		}
		else
		{
			$mem[$_] = ord($mem[$_]);
		}
	}
}
open(F,'<mem.hex') or die "$!";
$pam = <F>;
close F;
RAM($pam);

sub getmem
{
	return($mem[$_[0]]);
}
sub setmem
{
	$mem[$_[0]] = $_[1];
}
sub readcom
{
	return($mem[$_[0]],$mem[$_[0]+1]);
}
#------------------------------------------------

##I
#--Указатель комманд(ip): установка и получение--
$IP->{val} = 0;
sub getvalIP
{
	return($IP->{val});
}
		 
sub setvalIP {
  $val = $_[0];
  $IP->{val} = $val;
}
#-----------------------------------------------

##I
#--------Регистр команд: адр. и опер. код-------
$RC->{oc} = 0;
$RC->{adr} = 0;
sub getocRC
{
	return($RC->{oc});
}

sub getadrRC
{
	return($RC->{adr});
}
		 
sub setcomRC {
  ($val1, $val2) = @_;
  $RC->{oc} = $val1;
  $RC->{adr} = $val2;
 }
#-------------------------------------------------

##I
#------------------Сумматор-----------------------
$ADD->{f} = 0;
$ADD->{s} = 0;
$ADDNEXT->{f} = 0;
$ADDNEXT->{s} = 0;
sub getresADDNEXT
{
	return($ADDNEXT->{f} + $ADDNEXT->{s});
}
sub getresADD
{
	return($ADD->{f} + $ADD->{s});
}
		 
sub setoperADD {
  ($val1, $val2) = ($_[0],$_[1]);
  $ADD->{f} = $val1;
  $ADD->{s} = $val2;
}
sub setoperADDNEXT {
  ($val1, $val2) = ($_[0],$_[1]);
  $ADDNEXT->{f} = $val1;
  $ADDNEXT->{s} = $val2;
}
%ADD;
%ADDNEXT;
#--------------------------------------------------------------

##II
#---------Команды и сигналы ДЕККОМ, обработка------------------
($i,$p,$op,$pereh,$pysk,$vzap1,$zam1,$zam2,$chist,$vib,$zapp)=
( 0, 0,  0,     0,    1,     0,    0,    0,     0,   0,    0);

sub kod0{($p,$op,$pereh)=(0,0,0);}
sub kod11{($i,$p,$op,$pereh)=(0,1,1,0);}
sub kod15{($i,$p,$op,$pereh)=(1,1,1,0);}
sub kod2{($p,$op,$pereh)=(2,0,0);}
sub kod21{($i,$p,$op,$pereh)=(0,1,2,0);}
sub kod25{($i,$p,$op,$pereh)=(1,1,2,0);}
sub kod31{($i,$p,$op,$pereh)=(0,1,3,0);}
sub kodFE{($p,$op,$pereh)=(4,hex 0xF,1);}
sub kodFF{($p,$op,$pereh)=(4,hex 0xF,0);}
sub kodF0{
	($prznk,$f)=@_;
	($p,$op,$pereh)=(4,hex 0xF,((substr($prznk,0,1)==0)?1:0));
}
sub kodF1{
	($prznk,$f)=@_;
	($p,$op,$pereh)=(4,hex 0xF,((substr($prznk,1,1)==0)?0:1));
}
sub kodF4{
	($prznk,$f)=@_;
	($p,$op,$pereh)=(4,hex 0xF,($f==0?1:0));
}
sub kodF5{
	($prznk,$f)=@_;
	($p,$op,$pereh)=(4,hex 0xF,($f==0?0:1));
}
%kod=
(
	'0' => \&kod0,
	'11' => \&kod11,
	'15' => \&kod15,
	'2' => \&kod2,
	'21' => \&kod21,
	'25' => \&kod25,
	'31' => \&kod31,
	'FE' => \&kodFE,
	'FF' => \&kodFF,
	'F0' => \&kodF0,
	'F1' => \&kodF1,
	'F4' => \&kodF4,
	'F5' => \&kodF5
);

sub setpar
{
	$code = $_[0];
	$code = sprintf "%x", $code;
	$code = "\U$code\E";
	
	if(
		$code eq '0' ||
		$code eq '11' ||
		$code eq '15' ||
		$code eq '2' ||
		$code eq '21' ||
		$code eq '25' ||
		$code eq '31' ||
		$code eq 'FE' ||
		$code eq 'FF' ||
		$code eq 'F0' ||
		$code eq 'F1' ||
		$code eq 'F4' ||
		$code eq 'F5'
	)
	{
		$kod{"$code"}->($_[1],$_[2]);
	}
	$zapp = ($p==0?1:0);
	$zam1 = ($p==1?1:0);
	$zam2 = ($p!=3?1:0);
	$vzap1= ($p==3?1:0);
	$vib  = $i;
	$chist=(!($p==2 or $p==3)?1:0);
	$pysk = (($code ne 'FF')?1:0);
};
#-----------------------------------------------------

##I
#----Принимает массив сигналов и возвращает нужный----
sub procMP
{
	$sig = shift(@_);
	return($_[$sig]);
}
#------------------------------------------------------

##I
#----------------Индекс-регистр------------------------
$IR->{val} = 0;
sub getvalIR
{
	return($IR->{val});
}
sub setvalIR
{
  $val = $_[0];
  $IR->{val} = $val;
}
#------------------------------------------------------

##I
#--------------Регистра общего назначения--------------
$RON->{comval} = 0;
$RON->{prznkval} = '00';
sub getcomRON
{
	return($RON->{comval});
}

sub getprznkRON
{
	return($RON->{prznkval});
}

sub setRON 
{
  ($val1, $val2) = @_;
  $RON->{comval} = $val1;
  $RON->{prznkval} = $val2;
}

#----------------------------------------------------------------

##II
#--------------Регистр ввода-вывода------------------------------
$RVV->{val} = 0;
$RVV->{fl} = 0;
sub setRVV {
  ($val1, $val2) = @_;
  $RVV->{val} = $val1;
  $RVV->{fl} = $val2;
}
sub getfRVV
{
  return $RVV->{fl};
}
#------------------------------------------------------------

##II
#----------Арифметико-логическое устройство------------------
$ALU->{res} = 0;
$ALU->{prznk} = '00';
sub signal0{
	($RONcont,$EA)=@_;
	$ALU->{res} = $RONcont;
}
sub signal1{
	($RONcont,$EA)=@_;
	$ALU->{res} = $EA;
}
sub signal2{
	($RONcont,$EA)=@_;
	$ALU->{res} = $RONcont+$EA;
}
sub signal3{
	($RONcont,$EA)=@_;
	$ALU->{res} = $RONcont-$EA;
}
%alu=
(
	'0' => \&signal0,
	'1' => \&signal1,
	'2' => \&signal2,
	'3' => \&signal3
);

sub procALU
{
	if(
		$_[0]==0 ||
		$_[0]==1 ||
		$_[0]==2 ||
		$_[0]==3
	)
	{
		$alu{"$_[0]"}->($_[1],$_[2])
	}
	$ALU->{prznk} = int($ALU->{res}!=0)."".int(($ALU->{res})>0);
};
sub getresALU
{
	return($ALU->{res});
}

sub getprznkALU
{
	return($ALU->{prznk});
}
#------------------------------------------------

#----------Цикл работы---------------------------
open(F,'>job.txt') or die "$!";
while(1)
{
	if($error{'RC'}){setcomRC(readcom(getvalIP));}
    if($error{'DC'}){setpar(getocRC,getprznkRON,getfRVV);}
	if($error{'ADD'}){setoperADD(getvalIR,getadrRC);}
	if($error{'ADDNEXT'}){setoperADDNEXT(getvalIP,2);}
	if($error{'IP'}){setvalIP(procMP($pereh,getresADDNEXT,getresADD));}
	if($error{'ALU'}){procALU($op,getcomRON,procMP($vib,getmem(getresADD),getresADD,0));}
	if($zapp  && $error{'ZAPP'}){setmem(getresADD,getresALU)};
	if($zam2  && $error{'ZAM2'}){setvalIR(procMP($chist,getresALU,0))};
	if($zam1  && $error{'ZAM1'}){setRON(getresALU,getprznkALU)};
	if($vzap1 && $error{'VZAP1'}){setRVV(getresALU,1)};
	print F getvalIP.'  '.getocRC.'  '.getadrRC.'  '.getvalIR."\r\n";
	if (!$pysk){exit;};
}
close F;

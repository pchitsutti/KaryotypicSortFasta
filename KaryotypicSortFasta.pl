#!/usr/bin/perl

# Sort fasta , fa file in karyotypic order.

use Shell qw(cp);
use File::Basename;
use File::Copy;
use File::Spec;
use File::Path;
use Scalar::Util qw(looks_like_number);

my $in = $ARGV[0];
my $out = $ARGV[1];

open (F, $in);

my $oldctg = '';
my @ctglist;

while(my $line = <F>){
  if(substr($line,0,1) eq '>'){
    my $header = $line;
    my @h = split(' ', $header);
    my $ctg = $h[0];
    $ctg =~ s/\>//;
    unless($ctg eq $oldctg){
      if($#ctglist >=0){close(T);}
      open(T, ">tmp.$ctg.fa");
      print ("Found contig : $ctg\n");
      $oldctg = $ctg;
      push (@ctglist, $ctg);
    }
    print T $header;
  }
  else{
    my $sequence = $line;
    print T $sequence;
  }
}
close(F);

my @primary;
my @nonref;

foreach my $ctg (@ctglist){
  if(looks_like_number($ctg)){push (@primary, $ctg);}
  elsif(lc($ctg) eq 'w'){push (@primary, 101);}
  elsif(lc($ctg) eq 'x'){push (@primary, 102);}
  elsif(lc($ctg) eq 'y'){push (@primary, 103);}
  elsif(lc($ctg) eq 'z'){push (@primary, 104);}
  elsif(lc($ctg) eq 'm'){push (@primary, 105);}
  elsif(lc($ctg) eq 'mt'){push (@primary, 106);}
  else{push (@nonref, $ctg);}
}
@primary = sort {$a <=> $b} @primary;
# @nonref = sort  @nonref;
my $cat = "cat ";
foreach my $ctg (@primary){
  # print ("primay $ctg\n");
  my $contig = $ctg;
  if($contig == 101){$contig = 'W';}
  elsif($contig == 102){$contig = 'X';}
  elsif($contig == 103){$contig = 'Y';}
  elsif($contig == 104){$contig = 'Z';}
  elsif($contig == 105){$contig = 'M';}
  elsif($contig == 106){$contig = 'MT';}
  my $ctgfile = "tmp.$contig.fa";
  $cat .= "$ctgfile ";
}
foreach my $ctg (@nonref){
  # print ("nonref $ctg\n");
  my $ctgfile = "tmp.$ctg.fa";
  $cat .= "$ctgfile ";
}
$cat .= "> $out";
print ($cat."\n");
system($cat);
system("rm tmp.*.fa");




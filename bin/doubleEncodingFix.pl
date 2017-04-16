#Script to remove double encoding. Needs to be run from Lib_UNO root. Takes a list of XML files as argument

#use File::Copy;

$ids=0;
$totalfinds=0;
$totalrepl=0;

#grab UNO.xml
open UNO, "UNO.xml" or die;
$uno=join('',<UNO>);
close UNO;

#grab a list of xml files
open FL, "$ARGV[0]" or die;

#go through the list of xml files
while (<FL>) {
  chomp;
  $filename=$_;
  #open the file
  open IN, $filename  or die "Unable to open filename $filename $!";
  $file=join('',<IN>);
  close IN;

  #get the importaint metadata stuff
  $id=$1 if $file =~ m|<Id>(.*)</Id>|g;
  $title=$1 if $file =~ m|<Title>(.*)</Title>|g;
  $tech=$1 if $file =~ m|<Technology>(.*)</Technology>|g;
  $data=$1 if $file =~ m|<Data>(.*)</Data>|sg;

  #we don't care if we are not part of a view
  next unless  $uno =~ m|$id|;
 
  $finds=0; 
  #see if there are any &amp; followed by another encoded char in the file
  while ( $data =~ m|(&amp;\S+?;)|g) {
    $finds++;
  }

#  if ($finds > 0 ) {
#    move($filename, "$filename.bak") or die "$filename $!";
#  }

  $replacements=0;
  while ( $file =~ s|&amp;(\S+?;)|&$1|s ) {
    $replacements++;
  }

  if ( $finds > 0 ) {
    print "$filename finds: $finds, replacements: $replacements\n";
  }
  if ( $finds != $replacements ) {
    print "Aborting, something wrong fixing file $filename\n";
  }
 
  open OUT,">$filename";
  print OUT $file;

}

close FL;

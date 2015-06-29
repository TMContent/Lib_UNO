#Script to check for duplicate articles, takes list of .xml files as argument. Needs to be run from Lib_UNO root. 

$ids=0;
$dupes=0;

#grab UNO.xml
open UNO, "UNO.xml" or die;
$uno=join(//,<UNO>);
close UNO;

#grab a list of xml files
open FL, "$ARGV[0]" or die;

#go through the list of xml files
while (<FL>) {

  #open the file
  open IN, $_  or die;
  $file=join(//,<IN>);
  close IN;

  #get the importaint metadata stuff
  $id=$1 if $file =~ m|<Id>(.*)</Id>|g;
  $title=$1 if $file =~ m|<Title>(.*)</Title>|g;
  $tech=$1 if $file =~ m|<Technology>(.*)</Technology>|g;

  #we don't care if we are not part of a view
  next unless  $uno =~ m|$id|;

  #see if we already have this title tech combo, if so got a dupe, otherwise add to list
  if (exists $titles->{$title}->{$tech}) {
    print "$titles->{$title}->{$tech}->{id}";
    print "|$id|$title\n";
    $dupes++;
  }
  else {
    $titles->{$title}->{$tech}->{id}=$id;
  }

}

close FL;


#add some stuff u#add some stuff up
foreach (keys  %$titles ){
  $key=$_;  
  foreach (keys $titles->{$key}) {
#    print "$key $_ $titles->{$key}->{$_}->{id}\n";
    $ids++;
  }
}

print "GUIDs $ids, DUPES $dupes\n";

#Script to ONLY replace Fortify SCA mappings. No additions are done with this script.  Csv file should be in format OLDGUID-NEWGUID


open MP, "$ARGV[0]" or die;

#grab fortify mapping file
open FM, "$ARGV[1]" or die;
$fm=join('',<FM>);
close FM;

#go through the list of files
$mpline=0;
while (<MP>) {
  $mpline++;
  s/\r//;
  chomp;
  @guidParts=split(/-/);
  $oldguid=join('-', $guidParts[0], $guidParts[1], $guidParts[2], $guidParts[3], $guidParts[4]);
  $newguid=join('-', $guidParts[5], $guidParts[6], $guidParts[7], $guidParts[8], $guidParts[9]);

  #find stuff
  $finding=0;
  while ($fm =~ m|$oldguid|sg) {
    $finding++;
  }
  if ($finding > 0 ) {
#     print "Found $finding of guid $oldguid\n";
  }

  #replace stuff
  $fm =~ s|$oldguid|$newguid|sg;
 
}
close MP;
print $fm;

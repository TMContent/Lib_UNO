#Script to create virtual mappings from exported csv file, should be in format OLDGUID-NEWGUID

#count lines in the ADD file
open MP, "$ARGV[0]" or die;
$mplines=0;
while (<MP>){$mplines++;}
close MP;

#count lines in the vitual-articles file
open VA, "./__Graph_Data/virtual-articles.json", or die;
while (<VA>){$valines++;}
close VA;

#create the new virtual-articles file
open VA, "./__Graph_Data/virtual-articles.json", or die;
open VA_NEW, ">", "./__Graph_Data/virtual-articles.json.new", or die;

#remove the ] from the last line and , from next to last line
while (<VA>) {
  $valine++;
  if ($valine==$valines-1) {
     s/}/},/;
  }
  if ($valine==$valines) {
     next;
  }
  print VA_NEW;
}


open MP, "$ARGV[0]" or die;
#go through the list of files
$mpline=0;
while (<MP>) {
  $mpline++;
  s/\r//;
  chomp;
  @guidParts=split(/-/);
  if ($mpline==$mplines) {
     print VA_NEW ("{ \"subject\": \"article-$guidParts[9]\",\t\"predicate\": \"alias\",\t\"object\": \"$guidParts[4]\" },\r\n");
     print VA_NEW  ("{ \"subject\": \"article-$guidParts[9]\",\t\"predicate\": \"alias\",\t\"object\": \"$guidParts[0]-$guidParts[1]-$guidParts[2]-$guidParts[3]-$guidParts[4]\" }\r\n");
     print VA_NEW  "]\r\n";
  }
  else {
     print VA_NEW ("{ \"subject\": \"article-$guidParts[9]\",\t\"predicate\": \"alias\",\t\"object\": \"$guidParts[4]\" },\r\n");
     print VA_NEW ("{ \"subject\": \"article-$guidParts[9]\",\t\"predicate\": \"alias\",\t\"object\": \"$guidParts[0]-$guidParts[1]-$guidParts[2]-$guidParts[3]-$guidParts[4]\" },\r\n");
  }
}
close MP;
close VA;
close VA_NEW;

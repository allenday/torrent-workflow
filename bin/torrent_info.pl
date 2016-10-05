#!/usr/bin/perl
use strict;
use lib $ENV{HOME}."/local/lib/perl5";

use Convert::Bencode;
use Data::Dumper;

my $torrent = shift @ARGV;
open(F,$torrent);
my $enc = join '', <F>;
close(F);

my $infohash = $torrent;
$infohash =~ s#.torrent##;

my $h = Convert::Bencode::bdecode($enc);
my $t = $h->{info};

my %res =();
$res{ name } = $t->{name};

if ( $t->{files} ) {
  $res{ length } = 0;

  foreach my $f ( @{ $t->{files} } ) {
    $res{ files_length } += $f->{ length };
    $res{ files }{ $t->{name} .'/'. join('/',@{$f->{path}}) } = $f->{length};
  }
}
else {
  $res{ files_length } = 0;
  $res{ length } = $t->{length};
  $res{ files }{ $t->{name} } = $t->{ length };
}

print sprintf(qq(UPDATE torrent SET name="%s", length=%s, files_length=%s WHERE infohash="%s";\n), $res{name}, $res{length}, $res{files_length}, $infohash);
foreach my $f ( sort keys %{ $res{ files } } ) {
  print sprintf(qq(INSERT IGNORE INTO path (infohash,path) VALUES ("%s","%s");\n), $infohash, $f);
}

__END__
print Data::Dumper::Dumper $t;

#single file
# {
#   'name' => 'video.mp4'
#   'pieces' => '[...binary...]',
#   'length' => '315589235',
# };

#directory
# {
#   'name' => 'containing_directory_name',
#   'files' => [
#     {
#       'path' => [
#TODO: doe sthis contain a list of containing folders?
#         'video1.mp4'
#       ],
#       'length' => '2337360275'
#     },
#     {
#       'path' => [
#         'video2.mp4'
#       ],
#       'length' => '2337360275'
#     }
#   ]
# }

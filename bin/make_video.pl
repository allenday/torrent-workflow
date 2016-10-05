#!/usr/bin/perl
use strict;
use POSIX;

#
# given an input video file and directory of
# t<timestamp>_HH:MM:SS_*jpg named files
# make video clips of duration $DURATION
#

#fixed height
#scale="trunc(oh*a/2)*2:240"
#fixed width
#scale="720:trunc(ow/a/2)*2"

my $DURATION = shift @ARGV;
my $INFILE = shift @ARGV;
my $INDIR = shift @ARGV;
my $OUTDIR = shift @ARGV;

mkdir( $OUTDIR );
opendir(D, $INDIR);
my @ents = sort readdir(D);
foreach my $ent ( @ents ) {
warn $ent;
  next unless $ent =~ m#^t([\d:]+)_([\d\.]+)_.*jpg#;
warn "ok";

  my $t = $2;
  my $hms = sec2hms( $t );

  my $outfile = sprintf(qq(t%s_%05.3f_clip:%02d.mp4), $hms, $t, $DURATION);
#warn "$t\t$hms\t$outfile";

  system(qq(~/local/bin/ffmpeg -ss $t -y -i "$INFILE" -vf scale="trunc(oh*a/2)*2:240" -t $DURATION $OUTDIR/$outfile));
}
closedir(D);

sub sec2hms {
  my $sec = shift;
  my $h = ($sec/(60*60))%24;
  my $m = ($sec/60)%60;
  my $s = $sec%60;
  my $hms = POSIX::strftime(qq(%H:%M:%S),$s,$m,$h,undef,undef,undef);
  return $hms;
}


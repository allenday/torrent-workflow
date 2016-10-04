#!/usr/bin/perl
use strict;
use File::Copy;
use POSIX;

#
# given an input video file and offset
# calculation method (scene cut detection,
# fixed time offset, etc), make frame captures
# as format t<timestamp>_HH:MM:SS_<method>.jpg
#

#fixed height
#scale="trunc(oh*a/2)*2:240"
#fixed width
#scale="720:trunc(ow/a/2)*2"

my $METHOD = shift @ARGV;
my $OUTDIR = shift @ARGV;
my $INFILE = shift @ARGV;

warn "METHOD=$METHOD";

mkdir(qq($OUTDIR));
mkdir(qq($OUTDIR/$METHOD));

if ( $METHOD eq "keyframe_scene:0.40" ) {
  my $FILTER = '0.40';
  system(qq(~/local/bin/ffmpeg -y -skip_frame nokey -i "$INFILE" -vf select="gt(scene\\,$FILTER)",scale="trunc(oh*a/2)*2:240" -an -vsync 0 $OUTDIR/$METHOD/x%05d_method:keyframe_scene:$FILTER.jpg -loglevel debug 2>&1 | grep --line-buffered 'select_out:0' > $OUTDIR/$METHOD.offsets));
  rename_offsets_jpg( $OUTDIR, $METHOD );

} elsif ( $METHOD eq "keyframe_scene:0.30" ) {
  my $FILTER = '0.30';
  system(qq(~/local/bin/ffmpeg -y -skip_frame nokey -i "$INFILE" -vf select="gt(scene\\,$FILTER)",scale="trunc(oh*a/2)*2:240" -an -vsync 0 $OUTDIR/$METHOD/x%05d_method:keyframe_scene:$FILTER.jpg -loglevel debug 2>&1 | grep --line-buffered 'select_out:0' > $OUTDIR/$METHOD.offsets));
  rename_offsets_jpg( $OUTDIR, $METHOD );

} elsif( $METHOD eq "timestep_300" ) {
  my $STEPSIZE = 300;
  system(qq(~/local/bin/ffmpeg -y -i "$INFILE" -r 1/$STEPSIZE -vf scale="trunc(oh*a/2)*2:240" -f image2 $OUTDIR/$METHOD/x%05d_method:timestep_step:$STEPSIZE.jpg));
  rename_timestep_jpg( $STEPSIZE, "$OUTDIR/$METHOD" );

} elsif ( $METHOD eq "timestep_60" ) {
  my $STEPSIZE = 60;
  system(qq(~/local/bin/ffmpeg -y -i "$INFILE" -r 1/$STEPSIZE -vf scale="trunc(oh*a/2)*2:240" -f image2 $OUTDIR/$METHOD/x%05d_method:timestep_step:$STEPSIZE.jpg));
  rename_timestep_jpg( $STEPSIZE, "$OUTDIR/$METHOD" );
}

sub rename_offsets_jpg {
  my $outdir = shift;
  my $method = shift;

  open(O, "$outdir/$method.offsets");
  my @offsets = ();
  while ( my $line = <O> ) {
    chomp $line;

    my @F = split /\s+/, $line;
    my $t = $F[5];
    $t =~ s/t://;
    push @offsets, $t;
  }
  close(O);
  opendir(D, "$outdir/$method");
  my @ents = sort readdir(D);
  closedir(D);
  foreach my $ent ( @ents ) {
    next unless $ent =~ m#^x(\d+)_(.+).jpg#;
    my $frame = $1;
    my $rest = $2;

    #offsets file is zero based, template filenames are one based
    my $t = $offsets[$frame -1];
    my $hms = sec2hms( $t );

    my $outfile = sprintf(qq(t%s_%05.3f_%s.jpg), $hms, $t, $rest);

    File::Copy::move( "$outdir/$method/$ent", "$outdir/$method/$outfile" );    
  }
}

sub rename_timestep_jpg {
  my $stepsize = shift;
  my $outdir = shift;

  my $t = 0;
  opendir(D, $outdir);
  my @ents = sort readdir(D);
  closedir(D);
  foreach my $ent ( @ents ) {
    next unless $ent =~ m#^x(\d+)_(.+).jpg#;
    my $frame = $1;
    my $rest = $2;

    my $hms = sec2hms( $t );

    my $outfile = sprintf(qq(t%s_%05.3f_%s.jpg), $hms, $t, $rest );

    $t += $stepsize;

    print qq(File::Copy::mv( "$outdir/$ent", "$outdir/$outfile" )\n);
    File::Copy::move( "$outdir/$ent", "$outdir/$outfile" );
  }
  closedir(D);
}

sub sec2hms {
  my $sec = shift;
  my $h = ($sec/(60*60))%24;
  my $m = ($sec/60)%60;
  my $s = $sec%60;
  my $hms = POSIX::strftime(qq(%H:%M:%S),$s,$m,$h,undef,undef,undef);
  return $hms;
}


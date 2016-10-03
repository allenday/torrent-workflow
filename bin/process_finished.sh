#!/bin/bash

#
# this is called on event.download.finished
# see rtorrent.rc for details
#

THIS="$1"
echo "THIS='$THIS'" >> $HOME/debug.log

FROM=$HOME/private/rtorrent/data
echo "FROM='$FROM'" >> $HOME/debug.log

DEST=$HOME/private/rtorrent/complete
echo "DEST='$DEST'" >> $HOME/debug.log

BASE=`basename "$1"`
echo "BASE='$BASE'" >> $HOME/debug.log

/bin/mv "$FROM/$THIS" "$DEST/$BASE" && /usr/bin/touch "$DEST/$BASE.moved"
echo "/bin/mv '$FROM/$THIS' '$DEST/$BASE' && /usr/bin/touch '$DEST/$BASE.moved'"

exit 0

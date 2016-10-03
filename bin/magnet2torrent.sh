#!/bin/bash

#
# takes magnet URL as input, creates file
# suitable for loading into rtorrent
#

# set your watch directory here
WATCH=~/private/rtorrent/watch

[[ "$1" =~ xt=urn:btih:([^&/]+) ]] || exit;
echo "d10:magnet-uri${#1}:${1}e" > "$WATCH/meta-${BASH_REMATCH[1]}.torrent"

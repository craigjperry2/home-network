#!/bin/bash -xv
#
# TITLE
#   snapshot.sh
# DESCRIPTION
#   NetApp filer snapshots for us with champagne tastes but lemonade pockets
# AUTHOR
#   Craig J Perry
# BUGS
#   None known - file at https://github.com/craigjperry2/home-network/issues
#

if [[ ! -d $1 || ! -d $2 ]]; then
  echo "usage: $0 <source-dir> <destination-dir>" > /dev/stderr
  exit 1
fi

SOURCE=$1
DEST=$2

# 10 day's worth of daily snapshots

echo rm -rf $DEST/daily.9

echo mv $DEST/daily.8 $DEST/daily.9
echo mv $DEST/daily.7 $DEST/daily.8
echo mv $DEST/daily.6 $DEST/daily.7
echo mv $DEST/daily.5 $DEST/daily.6
echo mv $DEST/daily.4 $DEST/daily.5
echo mv $DEST/daily.3 $DEST/daily.4
echo mv $DEST/daily.2 $DEST/daily.3
echo mv $DEST/daily.1 $DEST/daily.2
echo mv $DEST/daily.0 $DEST/daily.1

echo rsync -a --delete --link-dest=../daily.1 $SOURCE/ $DEST/daily.0/

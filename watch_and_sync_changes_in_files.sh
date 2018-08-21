#!/bin/bash

# this program watch a source dir directory then copy any dir or file created
# or updated to a targetdir respecting directories tree
# so it will add all new changes to a target dir in smilar directory
# directories and files configuration
SOURCEDIR="/sourcepath"
TARGETDIR="/targetpath"
LOGFILE="/tmp/watcher.log"
ERRORFILE="/tmp/wacher_error.log"
FIFO="/tmp/watcher.fifo"
NOWHERE="/dev/null"

# fifo configuration
if [ ! -e $FIFO ]; then mkfifo $FIFO; fi

# sync action launched after watching
function file_sync {
  # Isolate relative parents directories path in order to have same directories tree
  REGEX="$SOURCEDIR/(.*)"
  if [[ $1 =~ $REGEX ]]; then RELATIVEPATH=${BASH_REMATCH[1]}; fi
  # other way : RELATIVEPATH=`expr match "$1" '\\/relativepath_regexp\/\(.*\)'`
  # Separate directory creation and file update or creation
  if [ -d $1 ]
  then
    mkdir -p "$TARGETDIR/$RELATIVEPATH"
  else
    RELATIVEDIR=`dirname $RELATIVEPATH`
    COPYTARGETDIR="$TARGETDIR/$RELATIVEDIR"
    # Create folders if folders do not exist in target directory
    if [ ! -d $COPYTARGETDIR ]; then mkdir -p $COPYTARGETDIR; fi
    # sync the file in the good directory
    sudo rsync $1 $NEWTARGETDIR
  fi
  echo "$2 $1 successfully synced in $NEWTARGETDIR" >>$LOGFILE
}

# Clean exit : Kill parallel inotifywait process and catching infos loop
function on_exit {
  kill $INOTIFY_PID
  rm $FIFO
  exit 0
}

# Watch function that uses INOTIFY TOOLS (need to be installed)
# Install inotify-tools before : sudo apt-get install intotify-tools
inotifywait -m -r -e create -e modify --exclude ".*\.[s][w][p]$" --timefmt '%Y-%m-%d %H:%M:%S' --format '%T %e %f %w' $DIR >$FIFO 2>>$ERRORFILE &
# catch process id in order to kill it on exit
INOTIFY_PID=$!
# Use correct exit function
trap "on_exit" 2 3 15
# Loop catching events stdout to launch actions
while read date time event file directory
do
  echo "LOG $date $time $event $file IN $directory" >> $LOGFILE
  PATHFILE="$directory$file"
  file_sync $PATHFILE $event
done < $FIFO

on_exit

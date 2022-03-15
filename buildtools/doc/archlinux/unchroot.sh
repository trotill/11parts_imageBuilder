#!bin/sh

DIR=$1
umount $DIR/proc
umount  $DIR/sys
umount $DIR/dev/pts
umount $DIR/dev


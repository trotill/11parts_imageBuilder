#!bin/sh

DIR=$1
if [ -z $DIR ]
then
 echo "Please set root dir"
else
  echo "select root dir" $DIR
    mount -t proc none $DIR/proc
    mount -t sysfs none $DIR/sys
    mount -o bind /dev $DIR/dev
    mount -o bind /dev/pts $DIR/dev/pts
    cp -L /etc/resolv.conf $DIR/etc
fi
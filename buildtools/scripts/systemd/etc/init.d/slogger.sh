#bin/sh

CONF_DIR=/www/pages/necron/Cnoda
SLOGGER=$CONF_DIR/safe_logger

#CONF_FILES=$(find $CONF_DIR -name *slogger.json)


#echo Found $CONF_FILES

export PATH="${PATH:+$PATH:}/usr/sbin:/sbin"
install -d /run/slogger

case "$1" in
  start)

		for entry in "$CONF_DIR"/*slogger.json
		do
		  echo Run $SLOGGER $entry
		  exec stdbuf -i0 -o0 -e0 $SLOGGER $entry | logger &
		done
	;;
  stop)

		for entry in "$CONF_DIR"/*slogger.json
		do
			echo Stop $SLOGGER $entry
		done
		killall -2 $SLOGGER
		
	;;

  restart)
		killall -2 $SLOGGER 
		for entry in "$CONF_DIR"/*slogger.json
		do
		  echo Restart $SLOGGER $entry  
		  exec stdbuf -i0 -o0 -e0 $SLOGGER $entry | logger &
		done
	;;

esac

exit 0
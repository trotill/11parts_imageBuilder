#!bin/sh


#echo idproduct $5>/dev/ttyS0
#echo idvendor $4>/dev/ttyS0
#echo magic $3>/dev/ttyS0
#echo msg $2>/dev/ttyS0
#echo dtype $1>/dev/ttyS0
msg=$2
dtype=$1
if [ "$dtype" == "usb" ];
	then
	  #echo USB device>/dev/ttymxc0
	  idvendor=$4
	  idproduct=$5
	  devpath=$(echo $3|cut -c 2-)
	  


		if [ -n "$devpath" ]; 
		then
			data='{"devp":"'$devpath'","vendor":"'$idvendor'","product":"'$idproduct'"}';
			message='{"t":[12,1],"d":{"'$msg'":'$data'}}'

			echo $message>>/run/exevents
			#echo debug $message>>/dev/ttyS0
		fi 
else
	#echo NOT USB device>/dev/ttymxc0
	if [ "$dtype" == "net" ];
	then
		#echo NET device>/dev/ttymxc0
		devpath=$3
		nettype=$4
		netport=$5
		data='{"devp":"'$devpath'","type":"'$nettype'","port":"'$netport'"}';
		message='{"t":[12,1],"d":{"'$msg'":'$data'}}'
		#/www/pages/necron/Cnoda/evwdt $msg $data
		echo $message>>/run/exevents
	fi
fi


#{t:[12,1],d:{netadd:{"devp":"lo","type":"772","port":"0"}}}


#echo -------------------------->/dev/ttymxc0

function running-guest {
	# $1 = $guest

	export CLUSTER=/root/cluster.conf
	dsh -e -g xen "xl list $1 2>/dev/null | sed 1d"
}

function usage {
	echo
	echo " usage: ${0##*/} $@"
	echo
	exit 1
}

function log {
	time=`date +%Y-%m-%d-%H:%M:%S`

	echo $time - info: $@ >> /var/tmp/dnc.log

	unset time
}

function bomb {
	time=`date +%Y-%m-%d-%H:%M:%S`

	# show the error live before logging - in case cannot write to log file
	echo
	echo error: $@
	echo

	#echo $time - user=$user guestid=$guestid minor=$minor guest=$guest name=$name >> /var/log/dnc.error.log
	echo $time - error: $@ >> /var/tmp/dnc.error.log

	unset time
	exit 1
}

# defines $ip
function dec2ip {
	[[ -z $prefix ]] && echo function dec2ip requires \$prefix from /etc/dnc.conf && exit 1

	[[ -z $1 ]] && echo function dec2ip requires guestid as argument && exit 1
	guestid=$1

	# dec2hex
        tmp=`printf "%x" $guestid`

	if (( `echo -n $tmp | wc -c` < 2 )); then
		tmp=000$tmp
	elif (( `echo -n $tmp | wc -c` < 3 )); then
                tmp=00$tmp
        elif (( `echo -n $tmp | wc -c` < 4 )); then
                tmp=0$tmp
	fi

        c=`echo $tmp | sed -r 's/(..)../\1/'`
        d=`echo $tmp | sed -r 's/..(..)/\1/'`
	unset tmp # will this break set -e in case $tmp wasn't necessary?

	(( debug > 0 )) && echo c is $c
	(( debug > 0 )) && echo d is $d

	# prefix from config and /16 suffix from hex
        ip=$prefix.$(( 0x$c )).$(( 0x$d ))

	unset tmp c d
}


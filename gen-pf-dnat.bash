#!/bin/bash
set -e

# TODO try with ksh instead

function dec2ip {
        [[ -z $guestid ]] && echo function dec2ip requires \$guestid && exit 1

        # hex from dec
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

        # /16 suffix from hex
        ip=10.1.$(( 0x$c )).$(( 0x$d ))

        unset tmp c d
}

cat <<EOF

nat on xennet0 inet from 10.1.0.0/16 to any -> 217.19.208.157

EOF

# sample rules up to 3000/tcp
for guestid in `seq 1 3000`; do
        dec2ip # defines ip
        echo "rdr on xennet0 inet proto tcp from any to any port $guestid -> $ip port 22"
        unset port ip
done
unset guestid

cat <<EOF

set skip on lo
#set skip on carp
#set skip on pfsync

pass in all
pass out all

EOF


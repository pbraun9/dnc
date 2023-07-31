#!/bin/bash

debug=0

source /etc/dnc.conf
source /usr/local/lib/dnclib.bash

# network is 10.1.0.0/16: 10.1.0.1 - 10.1.255.255
# guestid matches tcp port
# internal guests start at 1
# user guests start at 1024

# sample rules up to 3000/tcp
for guestid in `seq 1 3000`; do
	dec2ip # defines ip
	cat <<EOF
                iif \$nic tcp dport $guestid dnat $ip:22;
EOF
	unset port ip
done
unset guestid


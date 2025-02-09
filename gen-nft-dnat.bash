#!/bin/bash

debug=0

source /etc/dnc.conf
source /usr/local/lib/dnclib.bash

#  https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
# guestid matches tcp port + 49 152 (start of the non-iana registrated port range)
# internal guests	-- 49 152 to 49 199 (max 47 guests)
# user guests 		-- 49 200 to 65 535 (max 16 335 guests)
# and exception is 22/tcp dnat to point to the nobudget guest

# sample rules up to 347 guests
for guestid in `seq 1 347`; do
	dec2ip $guestid # defines $ip
	cat <<EOF
                iif \$nic tcp dport $(( guestid + 49200 )) dnat $ip:22;
EOF
	unset port ip
done
unset guestid



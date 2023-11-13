#!/bin/bash

echo

echo vrrp
dsh -e -g xen pgrep -a keepalived
#dsh -e -g xen tail -2 /var/tmp/keepalive.log
echo

echo state tracker
dsh -e -g xen pgrep -a conntrackd
echo

echo external vrrp
dsh -e -g xen ip addr show xenbr0 | grep \\.157
echo

echo internal vrrp
dsh -e -g xen ip addr show guestbr0 | grep \\.254
echo

echo snat
dsh -e -g xen nft list ruleset | grep snat
echo

if [[ -n $1 ]]; then
	port=$1
	dsh -e -g xen "conntrack -L | grep $port; echo internal cache; conntrackd -i | grep $port; echo external cache; conntrackd -e | grep $port"
	unset port
fi


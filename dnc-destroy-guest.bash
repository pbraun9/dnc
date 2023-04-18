#!/bin/bash

source /usr/local/lib/dnclib.bash

[[ -z $1 ]] && usage GUEST-NAME
guest=$1
guestpath=/data/guests/$guest

[[ ! -d $guestpath/ ]] && bomb ${0##*/} - $guestpath/ not found

# we are root already
node=`/usr/local/sbin/dnc-running-guest.bash $guest | cut -f1 -d:`
[[ -z $node ]] && bomb could not determine on what node guest $guest lives on
(( debug > 0 )) && echo guest $guest lives on $node

#echo brutally powering off guest $guest
echo
echo COLD POWER OFF GUEST $guest ON NODE $node
echo

ssh $node -t xl destroy $guest && echo DONE
echo


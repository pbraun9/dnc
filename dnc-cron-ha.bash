#!/bin/bash
set -e

# this script can be executed as a cron job on every node
# as a lame attempt for a distributed orchestrator
# symlink guests to auto-start into /etc/xen/auto-dnc/

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

[[ ! -x `which dsh` ]] && echo dsh executable not found && exit 1
[[ ! -x `which dnc-running-guests.bash` ]] && echo dnc-running-guests.bash executable not found && exit 1
[[ ! -x `which xl` ]] && echo xl executable not found && exit 1

node=`dsh -e -g pmr "xl info | grep ^free_memory" | sort -V -k3 -t: | tail -1 | cut -f1 -d:`

[[ ! $node = `hostname` ]] && exit 0

auto_dnc=`ls -1 /etc/xen/auto-dnc/`
for guest in $auto_dnc; do
	tmp=`dnc-running-guests.bash | grep ": $guest$"` || true
	[[ -z $tmp ]] && xl create /etc/xen/auto-dnc/$guest
	unset tmp
done; unset guest


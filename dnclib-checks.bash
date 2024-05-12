
[[ ! -d /etc/drbd.d/ ]] && bomb /etc/drbd.d/ not found

[[ ! -n $short ]] && short=${guest%%\.*}

# assuming fully distributed farm (all nodes can see every resource w/ diskless)
# not sure the resource has been named specifically, as it may have been created indepedently
if [[ -b /dev/drbd/by-res/$short/0 ]]; then
        res=$short
elif [[ -b /dev/drbd/by-res/dnc$slot/0 ]]; then
        res=dnc$slot
else
        bomb could not find drbd resource block device for $short
fi
drbdadm status $res >/dev/null || bomb DRBD RESOURCE $res HAS AN ISSUE

# /data/ is a shared across the farm
[[ -z `mount | grep ' on /data '` ]] && bomb /data/ is not mounted

[[ ! -d /data/guests/ ]] && bomb /data/guests/ not found
[[ ! -d /data/kernels/ ]] && bomb /data/kernels/ not found

# -z exists 1 and terminates the parent script set -e
# this is why there's -n here instead
[[ -n $pubkeys ]] || bomb missing \$pubkeys


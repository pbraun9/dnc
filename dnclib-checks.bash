
[[ ! -d /etc/drbd.d/ ]] && bomb /etc/drbd.d/ not found

[[ -z $guest ]] && bomb missing \$guest
drbdadm status $guest >/dev/null || bomb DRBD RESOURCE $guest HAS AN ISSUE

# /data/ is a shared across the farm
[[ -z `mount | grep ' on /data '` ]] && bomb /data/ is not mounted

[[ ! -d /data/guests/ ]] && bomb /data/guests/ not found
[[ ! -d /data/kernels/ ]] && bomb /data/kernels/ not found

# -z exists 1 and terminates the parent script set -e
# this is why there's -n here instead
[[ -n $pubkeys ]] || bomb missing \$pubkeys


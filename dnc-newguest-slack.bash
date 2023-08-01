#!/bin/bash
set -e

# 1. brutal network setup
# 2. ssh pub keys
# 3. xen guest skeleton

# no need for $tpl here since we already defined that while cloning the origin snapshot
[[ -z $2 ]] && echo ${0##*/} guest-id guest-name && exit 1
guestid=$1
guest=$2

source /etc/dnc.conf
source /usr/local/lib/dnclib.bash

# check drbd/lvm resource status
source /usr/local/lib/dnclib-checks.bash

# gw and friends got sourced by dnc.conf
# but guest ip gets eveluated by dec2ip function
dec2ip

[[ -z $ip ]] && bomb missing \$ip
[[ -z $gw ]] && bomb missing \$gw

echo
echo SLACKWARE SYSTEM PREPARATION
echo

# mounting a thin snapshot (already resized)
# drbd resource is possibly diskless

mkdir -p /data/guests/$guest/lala/

echo -n mounting reiser4 wa ...
mount -o defaults,noatime,nodiratime,txmod=wa,discard /dev/drbd/by-res/$guest/0 /data/guests/$guest/lala/ \
        && echo done || bomb failed to mount reiser4 for $guest

# TODO use absolute path instead
cd /data/guests/$guest/

echo -n hostname $guest ...
echo $guest > lala/etc/HOSTNAME && echo done

[[ -f lala/etc/hosts ]] && mv -i lala/etc/hosts lala/etc/hosts.dist
echo -n tuning /etc/hosts ...
cat > lala/etc/hosts <<EOF && echo done
127.0.0.1       localhost.localdomain localhost
::1		localhost.localdomain localhost
$ip     $guest.localdomain $guest
${ip%\.*}.254  gw
${ip%\.*}.253  dns1
${ip%\.*}.252  dns2
${ip%\.*}.251  dns3
EOF

# WARNING ESCAPES ARE IN THERE
echo -n rc.inet1 ...
cat > lala/etc/rc.d/rc.inet1 <<EOF && echo done
#!/bin/bash

echo rc.inet1 PATH is \$PATH

if [[ \$1 = stop || \$1 = down ]]; then
	/etc/rc.d/rc.sshd stop
	route delete default
	ifconfig eth0 down
	ifconfig lo down
else
	echo -n lo ...
	ifconfig lo up && echo done

	echo -n eth0 ...
	ifconfig eth0 $ip/16 up && echo done

	echo -n default route ...
	route add default gw $gw && echo done

	# self-verbose
	/etc/rc.d/rc.sshd start
fi
EOF
chmod +x lala/etc/rc.d/rc.inet1

# in case template had host keys within
echo clean-up ssh host keys
rm -f lala/etc/ssh/ssh_host_*
# NO NEED TO GENERATE NEW PAIRS ON SLACKWARE - ALL HOST KEYS GET GENERATED ANYHOW

echo -n adding pubkeys...
mkdir -p lala/root/.ssh/
cat > lala/root/.ssh/authorized_keys <<EOF && echo done
$pubkeys

EOF
chmod 700 lala/root/.ssh/
chmod 600 lala/root/.ssh/authorized_keys

echo -n un-mounting...
umount /data/guests/$guest/lala/ && echo done
rmdir /data/guests/$guest/lala/

echo -n writing guest config...
cat > /data/guests/$guest/$guest <<EOF && echo done
kernel = "/data/kernels/5.2.21.domureiser4.vmlinuz"
root = "/dev/xvda1 ro console=hvc0 mitigations=off"
#extra = "init=/bin/bash"
name = "$guest"
vcpus = 3
memory = 7168
disk = ['phy:/dev/drbd/by-res/$guest/0,xvda1,w']
vif = [ 'bridge=guestbr0, vifname=$guest' ]
type = "pvh"
EOF

echo

dnc-startguest-lowram.bash $guest


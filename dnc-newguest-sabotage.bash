#!/bin/bash
set -e

[[ -z $2 ]] && echo ${0##*/} guest-id guest-name && exit 1
guestid=$1
guest=$2

source /etc/dnc.conf
source /usr/local/lib/dnclib.bash
source /usr/local/lib/dnclib-checks.bash
dec2ip
[[ -z $ip ]] && bomb missing \$ip
[[ -z $gw ]] && bomb missing \$gw

echo
echo SABOTAGE SYSTEM PREPARATION
echo

mkdir -p /data/guests/$guest/lala/

echo -n mounting reiser4 wa ...
mount -o async,noatime,nodiratime,txmod=wa,discard /dev/drbd/by-res/$guest/0 /data/guests/$guest/lala/ \
        && echo done || bomb failed to mount reiser4 for $guest

cd /data/guests/$guest/

echo -n hostname $guest...
echo $guest > lala/etc/hostname && echo done

echo -n tuning /etc/hosts ...
cat > lala/etc/hosts <<EOF && echo done
127.0.0.1       localhost.localdomain   localhost
::1             localhost.localdomain   localhost
${ip%/*}	$guest
EOF

echo -n tuning /etc/resolv.conf ...
rm -f lala/etc/resolv.conf
cat > lala/etc/resolv.conf <<EOF && echo done
nameserver 10.1.255.252
nameserver 10.1.255.251
nameserver 10.1.255.253
EOF

echo -n tuning /etc/rc.local ...
#mv lala/etc/rc.local lala/etc/rc.local.tmp
#sed "s/ip=.*/ip=${ip%/*}/" lala/etc/rc.local.tmp > lala/etc/rc.local && echo done
#rm -f lala/etc/rc.local.tmp
sed "
	s/do_static_ip=.*/do_static_ip=true/;
	s/[[:space:]]ip=.*/ip=${ip%/*}/;
	s/[[:space:]]nm=.*/nm=255.255.0.0/;
	s/[[:space:]]gw=.*/gw=10.1.255.254/;
	" lala/etc/rc.local.dist > lala/etc/rc.local && echo done
chmod +x lala/etc/rc.local

echo clean-up ssh host keys
rm -f lala/etc/ssh/ssh_host_*
rm -f lala/etc/dropbear/*host_key*
# no need to generate new pairs

echo -n adding pubkeys...
mkdir -p lala/root/.ssh/
cat > lala/root/.ssh/authorized_keys <<EOF && echo done
$pubkeys

EOF
chmod 700 lala/root/.ssh/
chmod 600 lala/root/.ssh/authorized_keys

#
# override defaults from template
#

echo -n override template fstab ...
cat > lala/etc/fstab <<EOF && echo done
/dev/xvda1 / reiser4 async,noatime,nodiratime,txmod=wa,discard 0 1
devpts /dev/pts devpts gid=5,mode=620 0 0
tmpfs /dev/shm tmpfs defaults 0 0
proc /proc proc defaults 0 0
EOF

echo -n un-mounting...
umount /data/guests/$guest/lala/ && echo done
rmdir /data/guests/$guest/lala/

echo -n writing guest config...
cat > /data/guests/$guest/$guest <<EOF && echo done
kernel = "/data/kernels/5.2.21.domureiser4.vmlinuz"
root = "/dev/xvda1 ro console=hvc0 mitigations=off"
#extra = "init=/bin/mksh"
name = "$guest"
vcpus = 3
memory = 7168
disk = ['phy:/dev/drbd/by-res/$guest/0,xvda1,w']
vif = [ 'bridge=guestbr0, vifname=dnc$guestid.0',
	'bridge=guestbr0, vifname=dnc$guestid.1' ]
type = "pvh"
EOF

echo

dnc-startguest-lowram.bash $guest


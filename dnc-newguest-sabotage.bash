#!/bin/bash
set -e

[[ -z $1 ]] && echo usage: "${0##*/} <drbd minor> [guest hostname]" && exit 1
slot=$1
[[ -n $2 ]] && guest=$2 || guest=dnc$slot

short=${guest%%\.*}

source /etc/dnc.conf
source /usr/local/lib/dnclib.bash
source /usr/local/lib/dnclib-checks.bash

[[ -z $slot ]] && bomb missing \$slot
[[ -z $guest ]] && bomb missing \$guest
[[ -z $res ]] && bomb missing \$res

alive=`dsh -e -g xen "xl list | grep -E \"^$guest[[:space:]]+\"" | cut -f1 -d:`
[[ -n $alive ]] && echo $guest already lives on $alive && exit 1

dec2ip $slot

[[ -z $ip ]] && bomb missing \$ip
[[ -z $gw ]] && bomb missing \$gw

echo
echo \ SABOTAGE SYSTEM PREPARATION \($res\)
echo

mkdir -p /data/guests/$guest/lala/

function mount_reiser4 {
	echo -n mounting reiser4 ...
	mount -t reiser4 -o noatime,nodiratime,txmod=wa,discard /dev/drbd/by-res/$res/0 /data/guests/$guest/lala/ \
		&& echo done || bomb failed to mount reiser4 for $guest
	# async
}

function mount_ext4 {
        echo -n mounting ext4 ...
        mount -t ext4 -o noatime,nodiratime /dev/drbd/by-res/$res/0 /data/guests/$guest/lala/ \
                && echo done || bomb failed to mount ext4 for $guest
	# async

}

echo checking file-system type ext4 vs. reiser4
if tune2fs -l /dev/drbd/by-res/$res/0 >/dev/null 2>&1; then
	mount_ext4
else
	mount_reiser4
fi

cd /data/guests/$guest/

echo -n hostname $short ...
echo $short > lala/etc/hostname && echo done

echo -n tuning /etc/hosts ...
cat > lala/etc/hosts <<EOF && echo done
127.0.0.1       localhost.localdomain   localhost
::1             localhost.localdomain   localhost

${ip%/*}	$short

EOF

echo -n tuning /etc/resolv.conf ...
cat > lala/etc/resolv.conf <<EOF && echo done
nameserver 208.67.222.222
nameserver 208.67.220.220
EOF
#nameserver 10.1.255.252
#nameserver 10.1.255.251
#nameserver 10.1.255.253

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

echo clean-up openssh host keys
rm -f lala/etc/ssh/ssh_host_*
# no need to generate new pairs

echo clean-up dropbear host keys
#rm -f lala/etc/dropbear/*host_key*
rm -f lala/etc/dropbear/dropbear_*_host_key*
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

#echo -n override template fstab ...
#cat > lala/etc/fstab <<EOF && echo done
#/dev/xvda1 / reiser4 async,noatime,nodiratime,txmod=wa,discard 0 1
#devpts /dev/pts devpts gid=5,mode=620 0 0
#tmpfs /dev/shm tmpfs defaults 0 0
#proc /proc proc defaults 0 0
#EOF

#
# done tuning the guest image
#

echo -n un-mounting...
umount /data/guests/$guest/lala/ && echo done
rmdir /data/guests/$guest/lala/

echo -n writing guest config...
cat > /data/guests/$guest/$guest <<EOF && echo done
kernel = "/data/kernels/5.2.21.domureiser4.vmlinuz"
root = "/dev/xvda1 ro console=hvc0 mitigations=off"
#extra = "init=/bin/mksh"
name = "$guest"
vcpus = 1
memory = 1024
disk = ['phy:/dev/drbd/by-res/$res/0,xvda1,w']
vif = [ 'bridge=guestbr0, vifname=dnc$slot.0',
	'bridge=guestbr0, vifname=dnc$slot.1' ]
type = "pvh"
EOF

echo

dnc-startguest-lowram.bash $guest


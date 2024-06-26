#!/bin/bash
set -e

#
# no need for $tpl here since we already defined that while cloning the origin snapshot
#

[[ -z $1 ]] && echo usage: "${0##*/} <drbd minor> [guest hostname]" && exit 1
slot=$1
[[ -n $2 ]] && guest=$2 || guest=dnc$slot

short=${guest%%\.*}

source /etc/dnc.conf
source /usr/local/lib/dnclib.bash

# check drbd/lvm resource status
# and define $res
source /usr/local/lib/dnclib-checks.bash

[[ -z $slot ]] && bomb missing \$slot
[[ -z $guest ]] && bomb missing \$guest
[[ -z $res ]] && bomb missing \$res

alive=`dsh -e -g xen "xl list | grep -E \"^$guest[[:space:]]+\"" | cut -f1 -d:`
[[ -n $alive ]] && echo $guest already lives on $alive && exit 1

# gw and friends got sourced by dnc.conf
# but guest ip gets eveluated by dec2ip function
dec2ip $slot

[[ -z $ip ]] && bomb missing \$ip
[[ -z $gw ]] && bomb missing \$gw

echo
echo \ DEBIAN SYSTEM PREPARATION
echo

# note drbd resource is possibly diskless

mkdir -p /data/guests/$guest/lala/

# we have two kinds of debian templates BTRFS and REISER4
#btrfs check --readonly /dev/drbd/by-res/$guest/0 >/dev/null 2>&1 && fs=btrfs || fs=reiser4
#dd if=/dev/drbd/by-res/$guest/0 bs=1M count=1 2>/dev/null | hexdump -C | grep BHRfS >/dev/null 2>&1 && fs=btrfs || fs=reiser4

function mount_reiser4 {
	echo -n mounting reiser4 ...
	mount -t reiser4 -o noatime,nodiratime,txmod=wa,discard /dev/drbd/by-res/$res/0 /data/guests/$guest/lala/ \
		&& echo done || bomb failed to mount reiser4 for $guest
	# async
}

function mount_btrfs {
	# not sure why that command doesn't return 0 although it succeeds
	echo mounting butter-fs ...
	mount -t btrfs -o compress=lzo /dev/drbd/by-res/$res/0 /data/guests/$guest/lala/
	# (already resized)
}

#[[ ! -x `which btrfs` ]] && bomb missing btrfs command
echo checking file-system type butter-fs vs. reiser4
if btrfs filesystem show /dev/drbd/by-res/$res/0 >/dev/null 2>&1; then
	mount_btrfs
else
	mount_reiser4
fi

# TODO use absolute path all script long instead of entering the folder
cd /data/guests/$guest/

#echo -n erasing previous /etc/fstab from template...
#cat > lala/etc/fstab <<EOF && echo done
#/dev/xvda1 / btrfs rw,noatime,nodiratime,space_cache=v2,compress=lzo,discard 0 0
#devpts /dev/pts devpts gid=5,mode=620 0 0
#tmpfs /tmp tmpfs rw,nodev,nosuid,noatime,relatime 0 0
#proc /proc proc defaults 0 0
#EOF

echo -n hostname $short ...
echo $short > lala/etc/hostname && echo done

# ip got defined by dec2ip
#echo -n tuning /etc/hosts ...
#echo 127.0.0.1 localhost.localdomain localhost > lala/etc/hosts
#echo ::1 localhost.localdomain localhost >> lala/etc/hosts
#echo ${ip%/*} $short.localdomain $short >> lala/etc/hosts
#[[ -n $gw ]] && echo $gw gw.localdomain gw >> lala/etc/hosts && echo done

# here sourcing var names, not vars themselves (requires BASH)
#echo adding dns entries to /etc/hosts
#for dns in dns1 dns2 dns3 dns4; do
#        [[ -n ${!dns} ]] && echo ${!dns} $dns >> lala/etc/hosts
#done; unset dns

echo -n writing hosts ...
cat > lala/etc/hosts <<EOF && echo done
127.0.0.1       localhost.localdomain localhost
::1             localhost.localdomain localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

${ip%/*}	$short

EOF
#$dns0 dns0

# here sourceing the vars themselves
#echo -n erasing previous /etc/resolv.conf from tpl...
#rm -f lala/etc/resolv.conf
#for dns in $dns1 $dns2 $dns3 $dns4; do
#        echo nameserver $dns >> lala/etc/resolv.conf
#done && echo done; unset dns

echo -n tuning resolv.conf ...
cat > lala/etc/resolv.conf <<EOF && echo done
nameserver 208.67.222.222
nameserver 208.67.220.220
EOF
#nameserver 10.1.255.253
#nameserver 10.1.255.252
#nameserver 10.1.255.251

echo -n network/interfaces ...
cat > lala/etc/network/interfaces <<EOF && echo done
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
	address $ip/16
	gateway $gw

EOF

# in case template had host keys within
echo clean-up ssh host keys
rm -f lala/etc/ssh/ssh_host_*

# [FAILED] Failed to start OpenBSD Secure Shell server.
# we have better entropy on bare-metal anyway
#ssh-keygen -q -t dsa -f lala/etc/ssh/ssh_host_dsa_key -C root@$short -N ''
#ssh-keygen -q -t rsa -f lala/etc/ssh/ssh_host_rsa_key -C root@$short -N ''
echo generating ECDSA and EDDSA host keys
ssh-keygen -q -t ecdsa -f lala/etc/ssh/ssh_host_ecdsa_key -C root@$short -N ''
ssh-keygen -q -t ed25519 -f lala/etc/ssh/ssh_host_ed25519_key -C root@$short -N ''

echo -n adding pubkeys...
mkdir -p lala/root/.ssh/
cat > lala/root/.ssh/authorized_keys <<EOF && echo done
$pubkeys

EOF
chmod 700 lala/root/.ssh/
chmod 600 lala/root/.ssh/authorized_keys

# ADDITIONAL FIXUP - template out of sync
#echo -n writing sources.list ...
#cat > lala/etc/apt/sources.list <<EOF && echo done
#deb http://ftp.ro.debian.org/debian/ bullseye main contrib non-free
#deb http://ftp.ro.debian.org/debian/ bullseye-updates main contrib non-free
#deb http://ftp.ro.debian.org/debian/ bullseye-backports main contrib non-free
#deb http://security.debian.org/debian-security bullseye-security main contrib non-free
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
root = "/dev/xvda1 ro console=hvc0 net.ifnames=0 biosdevname=0 mitigations=off"
#extra = "init=/bin/bash"
name = "$guest"
vcpus = 3
memory = 7168
disk = ['phy:/dev/drbd/by-res/$res/0,xvda1,w']
vif = [ 'bridge=guestbr0, vifname=dnc$slot.0',
	'bridge=guestbr0, vifname=dnc$slot.1' ]
type = "pvh"
EOF
# netcfg/do_not_use_netplan=true
echo

#echo starting guest $guest
#xl create /data/guests/$guest/$guest && echo -e \\nGUEST $guest HAS BEEN STARTED
#echo up > /data/guests/$guest/state
dnc-startguest-lowram.bash $guest


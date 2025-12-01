# definitely not a cloud

_wrapper scripts for XEN/DRBD resource management_

_tested on slackware 15.0_

## requirements

### drbd on lvm2 or zfs

guest vdisks are stored on DRBD resources
which in turns live on
--either-- LVM thin pool
--or-- ZFS zvol

also guest vdisks can be resp.
--either-- LVM read-write snapshots
--or-- ZFS snapshot-clones (preferred)

setup a convergent
[XEN](https://pub.nethence.com/xen/slackware) /
[DRBD](https://pub.nethence.com/storage/drbd)
farm with
--either-- [LVM2 thin provisioning and read-write snapshots](https://pub.nethence.com/storage/lvm2)
--or-- [ZFS snapshot-clones](https://pub.nethence.com/storage/storage/zfs-snapshot-clones)

### shared-disk filesystem

guest configs and kernels are stored on shared filesystem,
be it scp-on-demand, NFS, GFS2 or OCFS2

setup some shared-disk filesystem for storing xen configs
--either-- [GFS2](https://pub.nethence.com/storage/gfs2)
--or-- [OCFS2](https://pub.nethence.com/storage/ocfs2)

	drbdadm status ocfs2
	ls -lhF /data/

for that purpose, we are expecting those directories

        mkdir -p /data/kernels/
        mkdir -p /data/guests/

        chmod 700 /data/kernels/
        chmod 700 /data/guests/

you can simply proceed as such while testing

_from node 1_

	rsync -av --delete /data/kernels/ $node:/data/kernels/
	rsync -av --delete /data/guests/ $node:/data/guests/

### clusterit / dsh

install [ClusterIt](https://www.garbled.net/clusterit)

	installpkg clusterit-2.5-x86_64-1_SBo.tgz

and setup your cluster

	vi /root/cluster.conf

	GROUP:xen
	node1
	node2
	node3

### network - bridges

DNC assumes a few different linux bridges,
a public one (or say home/lab network for testing)

	brctl show xenbr0

eventually an internal one for storage cluster and inter-node communication (optional)

	brctl show br0

and a guest network

	brctl show guestbr0

### network - dnat / pat on-demand

        slackpkg install nftables jansson libnftnl iptables libpcap dbus-1
	nft list ruleset

## install

	slackpkg install make guile gc

	git clone https://github.com/pbraun9/dnc
	cd dnc/
	make install

## setup

	cp dnc.conf.sample /etc/dnc.conf
	vi /etc/dnc.conf

## usage

see [USAGE.md](USAGE.md)


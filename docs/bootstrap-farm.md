# bootstrap a dnc farm incl. nobudget

## introduction

we first need to deploy the initial templates and guests with a local config file meanwhile /data becomes shared thanks to nobudget infrastructure guests.  their vdisk is replicated already, but the xen guest config lives on a network share as `/data/`, which is provided by the nobudget guests.

	mkdir -p /data_local/{guests,kernels,templates}/

	vi /etc/dnc.conf

	data=/data_local

also make your domU kernel of choice available there e.g.

	cd /data_local/kernels/
	wget https://lab.nethence.com/nunux/domU/6.1.49.domU.vmlinuz
	wget https://lab.nethence.com/nunux/domU/6.1.49.domU.modules.tar.gz
	wget https://lab.nethence.com/nunux/domU/6.1.49.domU.config

## some guest template

you first need a slackware or debian template,
see [template.md](template.md)

that goes in `/data_local/templates/` for now.

## nobudget1

you can now deploy the nobudget1 guest,
see [usage-partclone.md](usage-partclone.md)

that goes in `/data_local/guests/` for now.

prepare an additional vdisk resource for shared storage

	mkdir /data/
	touch /data/NOT_MOUNTED
	vi /etc/fstab

	/dev/xvdb /data ext4 defaults 1 2

	mount /data

setup an NFS server on that guest system

	vi /etc/exports

	/data 10.3.3.0/24(rw,sync,no_root_squash,no_subtree_check)

## nobudget2

_for NFS HA+LBS_

TBD

## VMM nodes

set NFS client on all VMM nodes

	slackpkg install network-scripts nfs-utils rpcbind
	chmod +x /etc/rc.d/rc.rpc
	/etc/rc.d/rc.rpc start

	vi /etc/fstab

	10.3.3.21:/data /data nfs rw,noatime,nodiratime,_netdev 0 0

	mount /data

<!--
setup an NFS share for `/data/` from nobudget1 guest and mount at boot-time on all the VMM nodes.
-->

<!--
you're now ready to apply the [vmm-dnc-nfs](...) role to nobudget1
-->

## storage migrate configs

the vdisks, be it templates or guests, are always distributed/mirrored.
however the the first configs live on node1 or node2 meanwhile nobudget1 and eventually nobudget2 rise up.
so once you got shared `/data/` in place, here's how to move those configs to it.

	mkdir -p /data/{guests,kernels,templates}/

first the existing local resources

	dnc-list-resources

e.g.

	mv -i /data_local/templates/* /data/templates/
	mv -i /data_local/guests/* /data/guests/
	rmdir /data_loca/templates/
	rmdir /data_loca/guests/

then a replica of the kernels you are using for your guests (it's good to keep a local copy also, for the node to be independent just in case)

	cp -R /data_local/kernels/* /data/kernels/

that's it you're good to go.  the only thing that was not shared already were the configs.

you're good to go

	vi /etc/dnc.conf

	# shared storage across VMM nodes
	data=/data


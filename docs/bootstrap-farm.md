# bootstrap a dnc farm incl. nobudget

## introduction

The vdisks, be it templates or guests, are always distributed/mirrored.
However the the first configs live on node1 or node2 meanwhile nobudget1 and eventually nobudget2 rise up.

We first need to deploy the initial templates and guests with a local config file meanwhile `//data/` becomes shared thanks to nobudget infrastructure guests.
Their vdisk are replicated already, but the xen guest config lives on a network share as `/data/`, which is provided by the nobudget guests.

	mkdir -p /data_local/{guests,kernels,templates}/

	vi /etc/dnc.conf

	data=/data_local

also make your domU kernel of choice is available there e.g.

	cd /data_local/kernels/
	wget https://lab.nethence.com/nunux/domU/6.1.49.domU.vmlinuz
	wget https://lab.nethence.com/nunux/domU/6.1.49.domU.modules.tar.gz
	wget https://lab.nethence.com/nunux/domU/6.1.49.domU.config

## some guest template

you first need a slackware and/or debian template

create the casual vdisks for those

	dnc-new-resource-vdisk slack1 slack2 5 slack150tpl
	dnc-new-resource-vdisk slack1 slack2 13 debian13tpl

bootstrap a system on those

        mkdir -p /data_local/templates/slack150tpl/lala/
        mkdir -p /data_local/templates/debian13tpl/lala/

        cd /data_local/templates/slack150tpl/
        cd /data_local/templates/debian13tpl/

and see [template-slackware.md](template-slackware.md) and/or [template-debian.md](template-debian.md)

now create the partclone image for those

        partclone.ext4 -c -s /dev/drbd5 | gzip --fast > /data_local/templates/slack150tpl.pcl.gz
        partclone.ext4 -c -s /dev/drbd13 | gzip --fast > /data_local/templates/debian13tpl.pcl.gz

notice that all goes in `/data_local/templates/` for now.

## nobudget guests

You can now deploy the nobudget guests based on that template image.

	dnc-new-resource-vdisk slack1 slack2 21 nobudget1
	dnc-new-resource-vdisk slack1 slack2 23 nobudget2

note. avoid slot 22 as we reject 22/tcp to avoid confusion

and a system on those

	dnc-partclone-deploy slack150tpl 21
	dnc-partclone-deploy debian13tpl 23

        dnc-newguest-debian 21 nobudget1
        dnc-newguest-debian 23 nobudget2

## nobudget nfs shares

Prepare an additional vdisk resource for shared storage

	dnc-new-resource-vdisk slack1 slack2 24 nobudget1_data
	dnc-new-resource-vdisk slack1 slack2 25 nobudget2_data

	vi /data_local/guests/{nobudget1,nobudget2}

	disk = ['phy:/dev/drbd24,xvdb,w']
	disk = ['phy:/dev/drbd25,xvdb,w']

<!-- todo use pvcreate instead -->
and in the nobudget guests

	mkdir /data/
	touch /data/NOT_MOUNTED
	vi /etc/fstab

	/dev/xvdb /data ext4 defaults 1 2
	/dev/xvdb /data ext4 defaults 0 2

	mount /data

setup an NFS server on that guest system

	(install nfs server packages)
	vi /etc/exports

	/data 10.3.3.0/24(rw,sync,no_root_squash,no_subtree_check)

## nobudget2

_for NFS HA+LBS_

TBD

## VMM nodes

setup an NFS client on all VMM nodes

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

Once you got shared `/data/` in place, here's how to move those configs to it.

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


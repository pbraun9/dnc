# Definitely Not a Cloud

_wrapper scripts for DRBD/XEN resource management_

_tested on slackware 15.0_

## Requirements

### drbd & shared-disk for xen configs

setup a convergent [DRBD](https://pub.nethence.com/storage/drbd)/[XEN](/xen/slackware) farm
with [LVM2 thin provisioning](https://pub.nethence.com/storage/lvm2) and some shared-disk [file](https://pub.nethence.com/storage/gfs2)-[system](https://pub.nethence.com/storage/ocfs2)

	drbdadm status ocfs2
	ls -lhF /data/

### cluster.conf

install [ClusterIt](https://www.garbled.net/clusterit) and setup your cluster

```
vi /root/cluster.conf

GROUP:xen
node1
node2
node3
...
```

## Shared storage

guest vdisks are stored on DRBD/LVM on the `thin` pool (see convergent DRBD farm guide linked above).

guest configs and kernels are stored on shared-disk file-system or network file-system (see the [storage guides](https://pub.nethence.com/storage/) accordingly, be it for NFS, GFS2 or OCFS2).
for that purpose, we are expecting those directories.

        mkdir -p /data/guests/ /data/kernels/
        chmod 700 /data/guests/ /data/kernels/

## Install

	git clone https://github.com/pbraun9/dnc
	cd dnc/
	make install

## Setup

	cp dnc.conf /etc/
	vi /etc/dnc.conf

## Guest templates summary

the newguest scripts are expecting a few things to be done already, as for [system preparation for the XEN guests](https://pub.nethence.com/xen/).
the guest templates are vanilla but for those changes.

- bashrc & completion
- timezone
- package repositories
- kernel modules (namely tmem)
- file index
- fstab

only those are the steps taken care of by the newguest scripts.

- network setup
- ssh host keys clean-up
- ssh authorized keys

although some steps can eventually be overwritten during guest deployments for convenience for example

- (fstab)
- (package repositories)

## Usage

### create a new drbd/lvm guest template

check for available drbd minor from the drbd/lvm template range (<1024)

	dnc-list-slots.bash

create a new guest template e.g. with drbd minor 7 on mirror nodes 1 and 2 (node 3 will reach the resource diskless)

        dnc-new-resource-template.bash node1 node2 7 debian12

proceed with the [debian bootstrap guide](https://pub.nethence.com/xen/guest-debian) against that new DRBD volume

        ls -lF /dev/mapper/thin-debian12
        ls -lF /dev/drbd7

### create a new guest (based on template)

check for available drbd slots

	dnc-list-slots.bash


what templates do we have?

	dnc-list-templates.bash

create a new snapshot-based drbd volume based on lvm template (here debian12)
<!--
note you might avoid the range used by nobudget (starts at 1024).
-->
-- for example let's say we want slot 41

        dnc-new-resource.bash debian12 41 <OPTIONAL RESOURCE NAME>

and finally post-tune the guest with the appropriate network settings

        dnc-newguest-debian.bash 41 <OPTIONAL HOSTNAME>

## ready to go

you can now reach the newly created guest on its dedicated tcp port (assuming DNAT on the load-balancer)

	ssh your.domain.tld -l root -p 41

<!--
## Distributed HA

here's a lame attempt for a HA scheduler
-- enable on every node

	*/5 * * * /usr/local/sbin/dnc-cron-ha.bash 2>&1
-->


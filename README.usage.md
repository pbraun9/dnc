# dnc usage for casual vdisks

	export PATH=/root/dnc:$PATH

## create a new drbd/lvm guest vdisk

check for available drbd slot
<!-- from the drbd/lvm template range (<1024) -->

        dnc-list-slots

	slot=5
	guest=slack150tpl

	slot=13
	guest=debian13tpl

	slot=21
	guest=nobudget1

	# avoid slot 22 as 22/tcp gets rejected to avoid confusion
	slot=23
	guest=nobudget2

create a new guest vdisk (or template which live on true vdisk just as full-blown guests)
e.g. with drbd slot `$slot` on mirror nodes 1 and 2

        dnc-new-resource-vdisk slack1 slack2 $slot $guest

note node3 and others, if they exist will reach the resource diskless

_for lvm2_

        ls -lF /dev/mapper/thin-$guest

_for zfs_

        ls -lF /dev/zvol/smith/$guest

_shared_

        #ls -lF /dev/drbd/by-res/$guest/0
        ls -lF /dev/drbd$slot

you can now proceed with a system bootstrap and template preparation,
either [as casual vdisk](README.template-vdisk.md)
or [as snapshot](README.template-snapshot.md)
against that new DRBD resource

let's assume from now on that `/dev/drbd$slot` contains a bootstrapped debian12 system.
note that the underlying volume, namely `/dev/mapper/thin-debian12` or `/dev/zvol/debian12`, contain not only the system but also the drbd headers.

then comes a choice.  --either-- you proceed with full-blown and independent vdisks,
which will leverage partclone-based templates

	dnc-partclone-deploy debian13tpl $slot
	dnc-partclone-deploy slack150tpl $slot

--or-- you proceed with snapshot-based templates (experimental)

## ready to go

_that's for intances not template images_

finally post-tune the guest with the appropriate network settings

        dnc-newguest-debian $slot <OPTIONAL HOSTNAME>
        dnc-newguest-slack $slot <OPTIONAL HOSTNAME>

you can now reach the newly created guest on its dedicated tcp port (assuming DNAT on the load
-balancer)

        ssh your.domain.tld -l root -p $slot

<!--
## Distributed HA

here's a lame attempt for a HA scheduler
-- enable on every node

        */5 * * * /usr/local/sbin/dnc-cron-ha 2>&1
-->


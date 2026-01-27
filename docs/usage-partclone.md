# dnc usage for partclone-based guests

## create a new guest vdisk

check for available drbd slot
<!-- from the drbd/lvm template range (<1024) -->

        dnc-list-slots

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

## depoy partclone template on it

proceed with full-blown and independent vdisks,
which will leverage partclone templates

	dnc-partclone-deploy debian13tpl $slot
	dnc-partclone-deploy slack150tpl $slot

## ready to go

back to [usage.md](usage.md)


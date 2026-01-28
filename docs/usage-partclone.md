# dnc usage for partclone-based guests

## create a new guest vdisk

check for available drbd slots

        dnc-list-slots

create a new guest vdisk (or template which live on true vdisk just as full-blown guests)
e.g. with drbd slot 1024 on mirror nodes 1 and 2

        dnc-new-resource-vdisk slack1 slack2 1024 that-resource

note node3 and others, if they exist will reach the resource diskless

## depoy partclone template on it

proceed with full-blown and independent vdisks,
which leverages partclone templates

	dnc-partclone-deploy debian13tpl $slot
	dnc-partclone-deploy slack150tpl $slot

## ready to go

back to [usage.md](usage.md)


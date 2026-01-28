# dnc usage for snapshot-based guests

_differential read-write snapshots that-is_

_DRAFT & EXPERIMENTAL (only somehow works with lvm2 not zfs snapshots just clone yet_

## create a new guest (based on template)

check for available drbd slots

	dnc-list-slots

what templates do we have?

	dnc-list-templates

create a new snapshot-based drbd resource based on underlying storage snapshots (here debian13tpl)
-- for example let's say we want drbd slot 1025

        dnc-new-resource-snapshot debian13tpl 1025 this-resource

## ready to go

back to [usage.md](usage.md)


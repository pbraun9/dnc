# dnc usage for differential vdisks

## create a new drbd/lvm guest template

same as for a casual vdisk,
see [README.usage.md](README.usage.md)

## create a new guest (based on template)

check for available drbd slots

	dnc-list-slots

what templates do we have?

	dnc-list-templates

create a new snapshot-based drbd volume based on lvm template (here debian12)
<!--
note you might avoid the range used by nobudget (starts at 1024).
-->
-- for example let's say we want slot 41

        dnc-new-resource-snapshot debian12 41 <OPTIONAL RESOURCE NAME>

## ready to go

back to [README.usage.md](README.usage.md)


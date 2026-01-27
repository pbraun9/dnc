# prepare templates on casual vdisks

_be it for partclone-based or snapshot-based guests_

## create a new guest vdisk

check for available drbd slot

        dnc-list-slots

	slot=5
	tpl=slack150tpl

	slot=13
	tpl=debian13tpl

	# for infrastructure instance without shared storage yet
	# see bootstrap-farm.md to setup shared storage
	data=/data_local

	# once shared storage is in place
	data=/data

## bootstrap guest templates

	mkdir -p $data/templates/$tpl/lala/
	cd $data/templates/$tpl/

	mkfs.ext4 /dev/drbd$slot
	mount /dev/drbd$slot lala/

### slackware

see [template-slackware.md](template-slackware.md)

### debian

see [template-debian.md](template-debian.md)

## templates for partclone-based guests

those guests require a partclone template to be available

prepare a partclone template for guests living on casual vdisks

        echo $data
        echo $slot
        echo $tpl

<!--
        partclone.ext4 -c -s /dev/drbd$slot -o $data/templates/$tpl.pcl
-->
        partclone.ext4 -c -s /dev/drbd$slot | gzip --fast > $data/templates/$tpl.pcl.gz

you can now eventually even delete the drbd resource and storage volumes on which this partclone template was based upon.
but if you plan to use snapshot-based guests, then at least the storage volumes need to remain alive.

## templates for snapshot-based guests

as for guests which live on either lvm2 snapshots or zfs snapshot clones, you don't have anything more to do.
the clones/snapshots are created on-the-fly with the `dnc-new-resource-snapshot` script.


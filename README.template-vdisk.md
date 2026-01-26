# prepare template for casual vdisks

	# for infrastructure instance without shared storage yet
	data=/data_local

	# once shared storage is in place
	data=/data

	mkdir -p $data/guests/$tpl/lala/

	cd $data/guests/$tpl/

	mkfs.ext4 /dev/drbd$slot

	mount /dev/drbd$slot lala/

	# required for additional package installation
	mkdir -p lala/dev/pts lala/proc
	mount -o bind /dev lala/dev
	mount -o bind /dev/pts lala/dev/pts
	mount -o bind /proc lala/proc

	#release=bookworm
	release=trixie
	country=de
	mirror=http://ftp.$country.debian.org/debian/

	ls -lhF /usr/share/keyrings/debian-archive-keyring.gpg
	time debootstrap --arch=amd64 $release lala $mirror
	rm -rf lala/var/cache/apt/archives/

	mount | grep lala/dev
	mount | grep lala/dev/pts
	mount | grep lala/proc
	chroot lala/ apt -y install openssh-server

	chroot lala passwd -d root

	umount -R lala/
	rmdir lala/
	echo debian $release bootstrapped `date -R` > README

let's assume from now on that `/dev/drbd$slot` contains a bootstrapped debian `$release` system.
note that the underlying volume, namely `/dev/mapper/thin-$tpl` or `/dev/zvol/smith/$tpl`, contain not only the system but also the drbd headers.

then comes a choice.  --either-- you proceed with full-blown and independent vdisks,
which will leverage partclone-based templates
--or-- you proceed with snapshot-based templates (experimental)

## full-blown partclone-based templates

	source /etc/dnc.conf

	mkdir -p $data/templates/

<!--
	partclone.ext4 -c -s /dev/drbd$slot -o $data/templates/$tpl.pcl
-->
	partclone.ext4 -c -s /dev/drbd$slot | gzip --fast > $data/templates/$tpl.pcl.gz


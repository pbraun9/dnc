# prepare template for casual vdisks

	mkdir -p $data/templates/

## requirements

	slot=5
	tpl=slack150tpl

	slot=13
	tpl=debian13tpl

	# for infrastructure instance without shared storage yet
	data=/data_local

	# once shared storage is in place
	data=/data

## setup

	mkdir -p $data/templates/$tpl/lala/
	cd $data/templates/$tpl/

	mkfs.ext4 /dev/drbd$slot
	mount /dev/drbd$slot lala/

### slackware

see https://pub.nethence.com/xen/guest-slackware
==> (only slackstrap is required, the rest is done within dnc-newguest-slack)

	slackstrap ...
	umount lala/
	rmdir lala/
	echo slackware 15.0 bootstrapped `date -R` > README

### debian

<!-- todo install locales -->

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

	umount -R lala/
	rmdir lala/
	echo debian $release bootstrapped `date -R` > README

### shared

let's assume from now on that `/dev/drbd$slot` contains a bootstrapped debian `$release` system.
note that the underlying volume, namely `/dev/mapper/thin-$tpl` or `/dev/zvol/smith/$tpl`, contain not only the system but also the drbd headers.

then comes a choice.  --either-- you proceed with full-blown and independent vdisks,
which will leverage partclone-based templates
--or-- you proceed with snapshot-based templates (experimental)

## full-blown partclone-based templates

	echo $data
	echo $slot
	echo $tpl

<!--
	partclone.ext4 -c -s /dev/drbd$slot -o $data/templates/$tpl.pcl
-->
	partclone.ext4 -c -s /dev/drbd$slot | gzip --fast > $data/templates/$tpl.pcl.gz


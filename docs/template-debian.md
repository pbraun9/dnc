# bootstrap debian on casual vdisk

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


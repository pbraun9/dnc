# bootstrap slackware on casual vdisk

<!-- todo prepare slackpkgs/mirrors -->

	cd /data/templates/
        wget https://pub.nethence.com/bin/slackstart/slackstrap.bash
        chmod +x slackstrap.bash

only slackstrap is required, the rest is done by the dnc-newguest-slackware script

	cd /data/templates/$tpl/
        wget https://pub.nethence.com/bin/slackstart/slackstart.conf
        vi slackstart.conf

        mirror=http://ftp6.gwdg.de/pub/linux/slackware/slackware64-15.0/

        time ../slackstrap.bash lala

	umount lala/
	rmdir lala/
	echo slackware 15.0 bootstrapped `date -R` > README


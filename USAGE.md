# dnc usage

## create a new drbd/lvm guest template

check for available drbd minor from the drbd/lvm template range (<1024)

	dnc-list-slots.bash

create a new guest template e.g. with drbd minor 7 on mirror nodes 1 and 2 (node 3 will reach the resource diskless)

        dnc-new-resource-template.bash node1 node2 7 debian12

proceed with the [debian bootstrap guide](https://pub.nethence.com/xen/guest-debian) against that new DRBD volume

        ls -lF /dev/mapper/thin-debian12
        ls -lF /dev/drbd7

## create a new guest (based on template)

check for available drbd slots

	dnc-list-slots.bash


what templates do we have?

	dnc-list-templates.bash

create a new snapshot-based drbd volume based on lvm template (here debian12)
<!--
note you might avoid the range used by nobudget (starts at 1024).
-->
-- for example let's say we want slot 41

        dnc-new-resource.bash debian12 41 <OPTIONAL RESOURCE NAME>

and finally post-tune the guest with the appropriate network settings

        dnc-newguest-debian.bash 41 <OPTIONAL HOSTNAME>

## ready to go

you can now reach the newly created guest on its dedicated tcp port (assuming DNAT on the load-balancer)

	ssh your.domain.tld -l root -p 41

<!--
## Distributed HA

here's a lame attempt for a HA scheduler
-- enable on every node

	*/5 * * * /usr/local/sbin/dnc-cron-ha.bash 2>&1
-->


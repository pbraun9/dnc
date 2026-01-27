# setting up dnc

## requirements

- slackware linux 15.0 (if you manage to make it all work on another system, let us know!)
- XEN
- Linux Bridge with three bridges: `xenbr0` (public/external), `br0` (cluster/storage), `guestbr0` (guests/internal)
- Linux Netfilter with the `nftables` frontend
- either LVM2 or ZFS (the latter is recommended if you plan to use snapshot-based guests, though it's also possible with LVM2)
- DRBD v9
- [ClusterIT](https://www.garbled.net/clusterit)

## install automation

those ansible playbooks might help:

https://pub.nethence.com/system/ansible/playbooks/vmm-xen/

https://pub.nethence.com/system/ansible/playbooks/vmm-dnc/

<!--
        export PATH=/root/dnc:$PATH

        mkdir -p $data/templates/
-->

## setup

the `/etc/dnc.conf` config file is also deployed by the playbooks,
see https://pub.nethence.com/system/ansible/playbooks/vmm-dnc/templates/dnc.conf


# definitely not a cloud

_wrapper scripts for XEN/DRBD resource management_

## architecture / features

### full convergence

We do Virtual Machine Monitor (VMM), here XEN + distributed storage with DRBD <!-- + NAT --> on the very same nodes.

This also goes for networking.  Every node has an external IP (be it public or private), and that's mainly how services within are reached.

### chain of mirrors

We are basically leveraging the DRBD v9 diskless feature, allowing to share vdisks across a whole storage cluster farm, not just nodes with a local replica.

### DNAT mapping

We setup a direct mapping between the DRBD resource ID of the guest (in fact a device minor, here called a DRBD slot),
and the DNAT tcp port that points to is as for SSH port-forwarding.
This allows users to reach their guest from the outside eventhough they do not necessarily have a public IP for their guest.

### template & guest naming convention

I usually add `tpl` as suffix for templates.  those have strictly casual vdisks (not snapshots of any kind) which are mirrored/distribued and their config lives in `$data/templates/`.

Let's consider drbd resource name `debian12_3` (underscores are allowed, we're not talking dns here).
guest config file sticks with that e.g. `$data/guests/debian12_3/debian12_3`.
only the hostname within the guest can be different but that's not our business (it's one layer above our area of responsability, as we're just providing infrastructure services).

## install

see [install.md](docs/install.md)

## setup

see [bootstrap-farm.md](docs/bootstrap-farm.md)

## usage

see [template.md](docs/template.md) and [usage.md](docs/usage.md)


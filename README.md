# definitely not a cloud

_wrapper scripts for XEN/DRBD resource management_

## install

see [install.md](docs/install.md)

## setup

see [bootstrap-farm.md](docs/bootstrap-farm.md)

## usage

see [template.md](docs/template.md) and [usage.md](docs/usage.md)

## additional notes

### template & guest naming convention

I usually add `tpl` as suffix for templates.  those have strictly casual vdisks (not snapshots of any kind) which are mirrored/distribued and their config lives in `$data/templates/`.

Let's consider drbd resource name `debian12_3` (underscores are allowed, we're not talking dns here).
guest config file sticks with that e.g. `$data/guests/debian12_3/debian12_3`.
only the hostname within the guest can be different but that's not our business (it's one layer above our area of responsability, as we're just providing infrastructure services).


# guest templates summary

the newguest scripts are expecting a few things to be done already
as for [system preparation for the XEN guests](https://pub.nethence.com/xen/).
the guest templates are vanilla but for those changes.

- bashrc & completion
- timezone
- package repositories
- kernel modules (namely tmem)
- file index
- fstab

only those are the steps taken care of by the newguest scripts.

- network setup
- ssh host keys clean-up
- ssh authorized keys

although some steps can eventually be overwritten during guest deployments for convenience for example

- (fstab)
- (package repositories)


# dnc usage

once you have a few [templates](template.md) in place, you can proceed.

here comes a choice.  --either-- you proceed with full-blown and independent vdisks,
which will leverage partclone-based templates
--or-- you proceed with snapshot-based templates (experimental)

## partclone-based guests

see [usage-partclone.md](usage-partclone.md)

## snapshot-based guests

see [usage-snapshot.md](usage-snapshot.md)

## ready to go

_only intances, not template vdisks_

finally post-tune the guest with the appropriate network settings

        dnc-newguest-debian $slot that-guest-hostname
        dnc-newguest-slackware $slot that-guest-hostname

you can now reach the newly created guest on its dedicated tcp port (assuming DNAT on the load-balancer)

        ssh your.domain.tld -l root -p $slot


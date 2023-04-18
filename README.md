# Definitely Not a Cloud

_wrapper scripts for DRBD/XEN resource management_

_tested on slack150_

## Requirements

- DRBD with LVM2 thin provisioning
- XEN

## Install

	git clone https://github.com/pbraun9/dnc
	cd dnc/
	make install

## Setup

	cp dnc.conf /etc/
	vi /etc/dnc.conf


#!/bin/bash
set -e

dsh -e -g xen "lvs | sed 1d" | while read lvdescr; do
	count_fields=`echo $lvdescr | awk '{ print NF }'`

	# with dsh output, first field is actually the node
	(( count_fields == 7 )) && echo $lvdescr | awk '{print $2}'

	unset count_fields
done | grep -vE 'pool|ocfs2' | sort -u

# https://stackoverflow.com/questions/5582405/number-of-fields-returned-by-awk


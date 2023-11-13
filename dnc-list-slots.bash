#!/bin/bash

cd /etc/drbd.d/
grep minor *.res | sort -k4 -V


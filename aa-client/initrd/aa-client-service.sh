#!/bin/bash -e

echo "SSS AA CLIENT SERVICE SSS 3333 $@"
#
echo "fetching key from KBS"

export AA_SAMPLE_ATTESTER_TEST=yes
aa-client --url http://10.0.2.2:5900 get-resource --resource-path default/keys/dummy

echo "unlocking rootfs"
# lsblk
# [ -e /etc/crypttab ] && cat /etc/crypttab
echo "SSS AA CLIENT SERVICE DONE SSS"


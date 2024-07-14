#!/bin/bash

SYSTEMDSYSDIR=/usr/lib/systemd/system
DRACUTMODDIR=/usr/lib/dracut/modules.d/
DRACUTAADIR=$DRACUTMODDIR/65aaclient
PREFIX=/usr/local
BINDIR=$PREFIX/bin

mkdir -p $DRACUTAADIR
install --mode 644 aa-client.service $SYSTEMDSYSDIR
install module-setup.sh $DRACUTAADIR
install aa-client-service.sh $BINDIR

echo 'run dracut -f'

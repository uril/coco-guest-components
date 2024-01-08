# Adding aa-client to initrd

## Summary
One can encrypt rootfs, and get the passphrase to decrypt it via remote attestation.

Currently KBS url is hard-coded, as well as the device to decrypt and the resource path. Also the passphrase is given in a file of the KBS container.


## How to test it on your laptop

### On the host:
I used port 5900 , use your favorite port, just enable it in the firewall
Allow port 5900

sudo firewallcmd --add-service vnc-server
sudo firewall-cmd --list-services

podman run --network=host -it quay.io/uril/coco-kbs-pubkey:2.3 /bin/bash

### inside the container
- change configuration file to listen on port 5900
  sed '3asockets = ["0.0.0.0:5900"]\n' config/kbs-config-pubkey.toml > config/kbs-new.toml

- run KBS with the new configuration file
  kbs --config-file config/kbs-new.toml &

- upload the dummy key to KBS
  kbs-client --url http://localhost:5900 config   --auth-private-key config/private.key set-resource --path default/keys/dummy --resource-file config/dummy_data

- test it locally
  AA_SAMPLE_ATTESTER_TEST=yes kbs-client --url http://localhost:5900 get-resource --path default/keys/dummy | base64 -d # verify it's 1234


### Run the VM (currently not really cVM):
Start with a RHEL-9 (likely works on Fedora and others too) VM, with an
encrypted rootfs (using luks) with a known (to you) passphrase (the following
is using the 'dummy' upstream example which is 1-90a-e
The first time you boot, unlock rootfs by entering the passphrase

- Open a terminal (e.g. gnome-shell)
#### If not done during installation, register the system such that dnf works
#### Install required packages
sudo dnf install git rust cargo make tpm2-tss-devel openssl-devel


- git clone the code
git clone https://github.com/uril/coco-guest-components -b simple-client-initrd
cd coco-guest-components/aa-client

- First make and install aa-client in the parent directory
make aa-client && sudo make install

- test aa-client running in the guest
export AA_SAMPLE_ATTESTER_TEST=yes
KBSURL=http://10.0.2.2:5900
RP=default/keys/dummy
aa-client --url $KBSURL get-resource --resource-path $RP | base64 -d


#### Now install and create initrd files
cd initrd

- Install binaries
Make sure the IP:port of KBS in *.sh are correct (or modify them).
sudo make install # to install initrd files

- Create a new initrd with aa-client
sudo make initrd

- Reboot the VM
/sbin/reboot

After reboot, hopefully the keyphrase will be provided by KBS after a successfully completed (test-session) remote attestation.

## In the guest
Open a terminal and look at the journalctl log - search for aa.client
journalctl -b

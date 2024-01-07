# Adding aa-client to initrd

[Summary]
One can encrypt rootfs, and get the passphrase to decrypt it via remote attestation.

Currently KBS url is hard-coded, as well as the device to decrypt and the resource path. Also the passphrase is given in a file of the KBS container.


[How to test it on your laptop]

On the host:
# I used port 5900 , use your favorite port, just enable it in the firewall
# Allow port 5900
sudo firewallcmd --add-service vnc-server
sudo firewall-cmd --list-services

podman run --network=host -it quay.io/uril/coco-kbs-pubkey:2.3 /bin/bash

# inside the container
  # change configuration file to listen on port 5900
  sed '3asockets = ["0.0.0.0:5900"]\n' config/kbs-config-pubkey.toml > config/kbs-new.toml
  # run KBS with the new configuration file
  kbs --config-file config/kbs-new.toml &

  # upload the dummy key to KBS
  kbs-client --url http://localhost:5900 config   --auth-private-key config/private.key set-resource --path default/keys/dummy --resource-file config/dummy_data

  # test it locally
  AA_SAMPLE_ATTESTER_TEST=yes kbs-client --url http://localhost:5900 get-resource --path default/keys/dummy | base64 -d # verify it's 1234


# Run the VM (currently not really cVM):
Start with a RHEL-9 (likely works on Fedora and others too) VM, with an
encrypted rootfs (using luks).
The first time you boot, unlock rootfs by entering the passphrase

# In a terminal
# If not done during installation, register the system such that dnf works
# Install required packages
sudo dnf install git rust cargo make tpm2-tss-devel openssl-devel


# fetch the code
git clone https://github.com/uril/coco-guest-components -b simple-client-initrd
cd coco-guest-components/aa-client

# First make and install aa-client in the parent directory
make aa-client && sudo make install

# Now install and create initrd files
cd initrd
# Make sure the IP:port of KBS in *.sh are correct (or modify them).

sudo make install # to install initrd files
sudo make initrd  # to create a new initrd with aa-client

/sbin/reboot

After reboot, hopefully the keyphrase will be provided by KBS after a successfully completed (test-session) remote attestation.

# In a terminal
journalctl -b # and search for aa.client

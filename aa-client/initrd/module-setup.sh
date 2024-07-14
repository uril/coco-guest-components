#!/bin/bash

check() {
    echo "UUU in aa-client-module-setup check($@) CHECK"
    # return 255
}

depends() {
    echo crypt systemd network
}

install () {
    echo "UUU in aa-client-module-setup install($@) INSTALL 3333"
    inst $systemdsystemunitdir/aa-client.service
    inst /usr/local/bin/aa-client-service.sh
    inst /usr/local/bin/aa-client
    # inst curl
    inst cryptsetup
    inst tr
    # inst head
    # inst nc
    inst mktemp
    inst base64
    inst /usr/lib/systemd/systemd-reply-password

    systemctl -q --root "$initdir" add-wants initrd.target        aa-client.service
    #systemctl -q --root "$initdir" add-wants cryptsetup.target        aa-client.service

    # need to figure out why systemd-unit-file get x mode
    chmod -x $systemdsystemunitdir/aa-client.service

    # need network -- figure out how to do it without chaning the command line
    echo "rd.neednet=1" > "${initdir}/etc/cmdline.d/65aa-client.conf"

    #echo "UUU $modir/aa-client-hook.sh"
    #ls /usr/lib/dracut/modules.d/65aaclient/aa-client-hook.sh
    #inst_hook pre-mount 65 /usr/lib/dracut/modules.d/65aaclient/aa-client-hook.sh
    echo "UUU in aa-client-module-setup install($@) INSTALL DONE"
}



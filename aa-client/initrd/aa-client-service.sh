#!/bin/bash -e

echo "*** AA CLIENT SERVICE *** 1111 $@"
#

KBSIP="10.2.0.4"
KBSPORT="5900"
KBSURL="http://${KBSIP}:${KBSPORT}"

PP_DIR=$(mktemp -d /tmp/PPXXXXXX)
PP_FILE=${PP_DIR}/aa-client-pp

SDAP=/run/systemd/ask-password

if [ ! -d "${SDAP}" ]; then
    echo "aa-client: No ${SDAP} directory -- exiting"
    return 0
fi


echo "aa-client: early: wait for ask file"
for i in 1 2 3 4 5 6 7 8 9 0; do
	sleep 1
	ls $SDAP/*.ask && break
done


for q in "${SDAP}"/ask.* ; do
	[ ! -e "$q" ] && continue
	echo "ASK FILE $q :" ; cat "$q"
	DISK=$(sed -n '/^Id=cryptsetup:/s/Id=cryptsetup://p' $q)
	SOCK=$(sed -n '/^Socket=/s/Socket=//p' $q)
	break
done


echo "DISK='$DISK' SOCK='$SOCK'"


for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
	echo "aa-client trying to fetch the passphrase from  ${KBSURL} === try number $i"

	aa-client --url ${KBSURL} get-resource --resource-path default/keys/dummy123456 > ${PP_FILE} && break
	sleep 1
done



if [ ! -s $PP_FILE ]; then
	echo 'FAILED TO GET PP via network'
	echo -n '123456' > $PP_FILE
else
	PP=$(cat $PP_FILE);
	echo "$PP" | base64 -d | tr -d '[:space:]' > $PP_FILE
	echo "GOT KEY '$(cat $PP_FILE)' ( $PP )"
fi


echo -n "Testing keyfile ..."
cryptsetup open --type luks --test-passphrase --key-file $PP_FILE  $DISK \
	&& echo " success" || echo " bad passphrase"

# see https://systemd.io/PASSWORD_AGENTS

cmd="cat $PP_FILE | /usr/lib/systemd/systemd_reply_password 1 $SOCK"
echo "aa-client: unlocking rootfs on '$DISK' with '$cmd'"
cat $PP_FILE | /usr/lib/systemd/systemd-reply-password 1 $SOCK \
	&& echo "Disk unlocked" || echo "Disk unlock FAILED"


echo "*** AA CLIENT SERVICE DONE ***"


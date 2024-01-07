#!/bin/bash -e

echo "SSS AA CLIENT SERVICE SSS 3334 $@"
#
echo "fetching key from KBS"

export AA_SAMPLE_ATTESTER_TEST=yes


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


if [ 1 == 1 ]; then # DO skip this part for now
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
	echo "aa-client trying to fetch the passphrase === try number $i"
	#nc 10.0.2.2 8080 | head -1 > ${PP_FILE}.NC && break
	#curl -s http://10.0.2.2/aa/pp -o ${PP_FILE} && break

	AA_SAMPLE_ATTESTER_TEST=yes \
	aa-client --url http://10.0.2.2:5900 get-resource --resource-path default/keys/dummy | base64 -d > ${PP_FILE} && break
	sleep 1
done
fi


#[ -e ${PP_FILE}.CURL ] && \
#	echo "aa-client: curl got '$(cat ${PP_FILE}.CURL)'"

if [ ! -s $PP_FILE ]; then
	echo 'FAILED TO GET PP via network'
	echo -n '1234567890abcde' > $PP_FILE
else
	PP=$(cat $PP_FILE);
	echo "$PP" | tr -d '[:space:]' > $PP_FILE
	echo "GOT KEY '$(cat $PP_FILE) '"
fi


echo -n "Testing keyfile ..."
cryptsetup open --type luks --test-passphrase --key-file $PP_FILE  /dev/vda1 luks-4e4c3ed7-3e37-4e25-b479-b89b007de2cb \
	&& echo " success" || echo " bad passphrase"

# see https://systemd.io/PASSWORD_AGENTS

cmd="cat $PP_FILE | /usr/lib/systemd/systemd_reply_password 1 $SOCK"
echo "aa-client: unlocking rootfs on '$DISK' with '$cmd'"
cat $PP_FILE | /usr/lib/systemd/systemd-reply-password 1 $SOCK \
	&& echo "Disk unlocked" || echo "Disk unlock FAILED"




# lsblk
# [ -e /etc/crypttab ] && cat /etc/crypttab
echo "SSS AA CLIENT SERVICE DONE SSS"


#!/bin/bash
export IFS=$'\n'
argv=("$@")
DIR=$(cd $(dirname $0); pwd)
cd $DIR
CMDNAME=`basename $0`
if [ $# -eq 0 ]; then
	echo "Usage : ${CMDNAME} [dirname]"
	exit 1
fi

## configuration
TMP_DIR=/var/tmp/crond
THRESHOLD_BITRATE=160
TARGET_BITRATE=320
TARGET_SAMPLING_RATE=48000
##


for TARGET_DIR in ${argv}
do
	for FILENAME in `find "${TARGET_DIR}" -name "*.mp3" | sort`
	do
		BITRATE=`soxi -B "${FILENAME}" | cut -d "k" -f 1 | cut -d "." -f 1`
		echo ''$FILENAME' : '$BITRATE' k'
		DIFF=$(( THRESHOLD_BITRATE - BITRATE ))
		if [ $(( DIFF )) -gt 1 ]  ; then
			echo "under threshold bitrate : ${THRESHOLD_BITRATE} . upconverting..."
			serial=`uuidgen`

			sox -S -G "${FILENAME}" -C ${TARGET_BITRATE} -r ${TARGET_SAMPLING_RATE} ${TMP_DIR}/${serial}.mp3 | continue
			rm "${FILENAME}" && mv ${TMP_DIR}/${serial}.mp3 "${FILENAME}"

			soxi "${FILENAME}"

			echo "done."
		fi
	done
done
rm ${TMP_DIR}/*.mp3

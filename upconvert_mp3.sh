#!/bin/bash
export IFS=$'\n'
argv=("$@")
CMDNAME=`basename $0`
if [ $# -eq 0 ]; then
	echo "Usage : ${CMDNAME} [dirname]"
	exit 1
fi

## https://qiita.com/hit/items/e95298f689a1ee70ae4a                                                                                                                                                               
_pcnt=`pgrep -fo ${CMDNAME} | wc -l`               
if [ ${_pcnt} -gt 1 ]; then                        
	echo "This script has been running now. proc : ${_pcnt}"
	exit 1                                           
fi

## configuration
TMP_DIR=/tmp
THRESHOLD_BITRATE=160
TARGET_BITRATE=320
TARGET_SAMPLING_RATE=48000
##


for ARG_DIR in ${argv}
do
	TARGET_DIR=`readlink -f ${ARG_DIR}`
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

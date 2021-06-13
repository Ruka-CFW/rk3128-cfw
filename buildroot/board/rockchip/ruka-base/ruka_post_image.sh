#!/bin/bash

NAME=$(whoami)
HOST=$(hostname)
DATETIME=`date +"%Y-%m-%d %H:%M:%S"`
TARGET=$1
MODEL=$2

NEW_ROOTFS="rootfs_${MODEL}.squashfs"
OLD_ROOTFS_PATH="${TARGET}/rootfs.squashfs"
NEW_ROOTFS_PATH="${TARGET}/${NEW_ROOTFS}"

echo "# Model: ${MODEL}"
echo "# Moving rootfs"
echo "  from: ${OLD_ROOTFS_PATH}"
echo "  to:   ${NEW_ROOTFS_PATH}"

mv ${OLD_ROOTFS_PATH} ${NEW_ROOTFS_PATH}

echo "renamed to ${NEW_ROOTFS} by ${NAME} on ${HOST} at ${DATETIME}" >> ${TARGET}/timestamp
exit 0

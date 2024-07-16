#!/bin/bash

set -e
set -x

ENV_TXT="$BR2_EXTERNAL"/env/env.txt
OUTPUT="$BR2_EXTERNAL"/output
EXT4_IMAGE="$OUTPUT"/data.ext4
MOUNTPOINT="$BASE_DIR"/superduperbird_data_mnt

cleanup() {
  echo "$0 failed"
  umount "$MOUNTPOINT" || /bin/true
  [ -f "$OUTPUT"/"$ENV_TXT" ] && rm "$OUTPUT"/"$ENV_TXT"
  [ -f "$EXT4_IMAGE" ] && rm "$EXT4_IMAGE"
  rm "$EXT4_IMAGE" && mv "$EXT4_IMAGE".backup "$EXT4_IMAGE"
  set +x
  return 1
}

[ -f "$OUTPUT"/"$ENV_TXT" ] && mv -f "$OUTPUT"/"$ENV_TXT" "$OUTPUT"/"$ENV_TXT".backup
[ -f "$EXT4_IMAGE" ] && mv -f "$EXT4_IMAGE" "$EXT4_IMAGE".backup

trap cleanup INT

# Based on the size of the data dump, 2G appears to be safe
dd if=/dev/zero of="$EXT4_IMAGE" bs=1M count=2048 || cleanup
mkfs.ext4 "$EXT4_IMAGE" || cleanup
mkdir "$MOUNTPOINT" || /bin/true
sudo mount -t ext4 -o loop "$EXT4_IMAGE" "$MOUNTPOINT" || cleanup
sudo tar -xf "$BINARIES_DIR"/rootfs.tar -C "$MOUNTPOINT" || cleanup
sudo umount "$MOUNTPOINT"

cp "$ENV_TXT" "$OUTPUT"/"$(basename $ENV_TXT)" || cleanup

set +x

#!/bin/bash

set -e
set -x

OUTPUT="$BR2_EXTERNAL"/output
ENV_TXT="$BR2_EXTERNAL"/board/env/env.txt
ENV_OUT="$OUTPUT"/env.txt
EXT4_IMAGE="$OUTPUT"/data.ext4
MOUNTPOINT="$BASE_DIR"/superduperbird_data_mnt
KERNEL_IMG="$BASE_DIR"/images/Image
KERNEL_OUT="$OUTPUT"/kernel.img
DTS="$BR2_EXTERNAL"/board/dt.dts
DTB="$OUTPUT"/dt.dtb

cleanup() {
  echo "$0 failed"

  umount "$MOUNTPOINT" || /bin/true

  # restore backups (if they exist)
  for outfile in "$ENV_OUT" "$EXT4_IMAGE" "$KERNEL_OUT" "$DTB"; do
    [ -f "$outfile" ] && rm "$outfile" && (mv "$outfile".backup "$outfile" || true)
  done

  set +x

  return 1
}

# make backups
for outfile in "$ENV_OUT" "$EXT4_IMAGE" "$KERNEL_OUT" "$DTB"; do
  [ -f "$outfile" ] && mv -f "$outfile" "$outfile".backup
done

trap cleanup INT

# Based on the size of the data dump, 2G appears to be safe
dd if=/dev/zero of="$EXT4_IMAGE" bs=1M count=2048 || cleanup
mkfs.ext4 "$EXT4_IMAGE" || cleanup
mkdir "$MOUNTPOINT" || /bin/true
sudo mount -t ext4 -o loop "$EXT4_IMAGE" "$MOUNTPOINT" || cleanup
sudo tar -xf "$BINARIES_DIR"/rootfs.tar -C "$MOUNTPOINT" || cleanup
sudo umount "$MOUNTPOINT"

cp "$ENV_TXT" "$OUTPUT"/"$(basename $ENV_TXT)" || cleanup

cp "$KERNEL_IMG" "$KERNEL_OUT" || cleanup

dtc -I dts -O dtb -o "$DTB" "$DTS" || cleanup

set +x

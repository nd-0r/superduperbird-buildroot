#!/bin/bash

# References:
# https://stackoverflow.com/questions/60552355/qemu-baremetal-emulation-how-to-view-uart-output
# https://web.archive.org/web/20180104171638/http://nairobi-embedded.org/qemu_monitor_console.html#nographic-mode

KERNEL="../buildroot-2024.05/output/images/vmlinux"  # Update this path
ROOTFS="./output/data.ext4"    # Update this path
INITARGS="init=/sbin/init ramoops.pstore_en=1 ramoops.record_size=0x8000 ramoops.console_size=0x4000 rootfstype=ext4 console=ttyAMA0 rw rootwait skip_initramfs root=/dev/vda"

# -serial mon:stdio \
# -device virtio-blk-device,drive=hd0 \

qemu-system-aarch64 \
  -machine virt \
  -cpu cortex-a53 \
  -m 512 \
  -display none \
  -kernel $KERNEL \
  -append "$INITARGS" \
  -drive if=none,file=$ROOTFS,format=raw,id=hd0 \
  -serial stdio


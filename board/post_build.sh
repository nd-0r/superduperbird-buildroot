#!/bin/sh

KERNEL_VERSION="4.9.113"

# Ensure the kernel modules directory exists
MODULES_DIR="$TARGET_DIR/lib/modules"
if [ -d "$MODULES_DIR" ]; then
    # Run depmod to generate module dependency and symbol information
    depmod -a -b "$TARGET_DIR" ${KERNEL_VERSION}
else
    echo "Modules directory $MODULES_DIR does not exist."
    exit 1
fi

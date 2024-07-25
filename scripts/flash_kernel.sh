#!/bin/bash

# Adapted from https://github.com/frederic/superbird-bulkcmd/blob/main/scripts/upload-kernel.sh

usage() {
  cat <<EOF
  Usage:
  $0 <path to Amlogic update tool>
EOF
}

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

UPDTOOL="$1"

$UPDTOOL partition boot_a ../output/kernel.img

# # Upload & boot kernel when U-Boot is in 'USB Burning' mode
# DIR=$(dirname $(realpath $0))
# KERNEL=$DIR/../output/kernel.img
# KERNEL_ADDR=0x01080000
# FDT=$DIR/../output/dt.dtb
# FDT_ADDR=0x13000000
# ENV=$DIR/temp-kernel-env.txt
# ENV_ADDR=0x13000000
# ENV_SIZE=`printf "0x%x" $(stat -c %s $ENV)`
# 
# $UPDTOOL bulkcmd "amlmmc env"
# $UPDTOOL write $ENV $ENV_ADDR
# $UPDTOOL bulkcmd "env import -t $ENV_ADDR $ENV_SIZE"
# $UPDTOOL write $KERNEL $KERNEL_ADDR
# $UPDTOOL write $FDT $FDT_ADDR
# echo 'Booting...'
# # $UPDTOOL bulkcmd "booti $KERNEL_ADDR - $FDT_ADDR"
# $UPDTOOL bulkcmd "booti $KERNEL_ADDR"


set -e

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
ENV=../output/env.txt
ENV_ADDR=0x13000000
ENV_SIZE=`printf "0x%x" $(stat -c %s $ENV)`

$UPDTOOL bulkcmd "amlmmc env"
$UPDTOOL write $ENV $ENV_ADDR
$UPDTOOL bulkcmd "env import -t $ENV_ADDR $ENV_SIZE"

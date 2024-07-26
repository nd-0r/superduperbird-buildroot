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
# SIZE="0x889EA000"
SIZE="0x8000000"
$UPDTOOL mread store data normal "$SIZE" "data.dump"

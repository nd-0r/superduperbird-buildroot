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
SIZE="0x4000000"
$UPDTOOL mread store system_b normal "$SIZE" "system.dump"

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
$UPDTOOL mread store env normal 0x800000 "env.dump"

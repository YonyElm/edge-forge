log() { echo "==> $*"; }
warn() { echo "WARN: $*" >&2; }
die() { echo "ERROR: $*" >&2; exit 1; }

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

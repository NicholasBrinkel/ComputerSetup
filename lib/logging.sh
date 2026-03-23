info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1" >&2; }

log() {
    local log_file="${LOG_FILE:-${SCRIPT_DIR}/setup.log}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$log_file"
}

banner() {
    echo ""
    echo -e "${BOLD}${CYAN}======================================${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}======================================${NC}"
    echo ""
}

confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-y}"
    local options="Y/n"
    [[ "$default" == "n" ]] && options="y/N"

    read -p "$prompt [$options]: " response
    response="${response:-$default}"
    [[ "${response,,}" =~ ^(y|yes)$ ]]
}

require() {
    command -v "$1" &>/dev/null || {
        error "$1 is required but not installed"
        exit 1
    }
}

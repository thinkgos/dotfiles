#!/usr/bin/env bash
#
# bootstrap.sh - Download and install GitHub release binaries
# Reads roles/github/vars/main.yml, downloads each app from GitHub releases,
# and installs binaries to /usr/local/bin/.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
YAML_FILE="${GHAPPS_YAML:-$SCRIPT_DIR/roles/github/vars/main.yml}"
INSTALL_DIR="${GHAPPS_DIR:-/usr/local/bin}"
UA="bootstrap.sh/1.0"

# ---------- logging ----------

info() { printf "\033[0;32m[info]\033[0m  %s\n" "$*"; }
warn() { printf "\033[0;33m[warn]\033[0m  %s\n" "$*"; }
error() { printf "\033[0;31m[error]\033[0m %s\n" "$*" >&2; }
die() {
    error "$@"
    exit 1
}

# ---------- network ----------

dl() {
    local max_retries=3

    if command -v curl &>/dev/null; then
        curl --proto '=https' --tlsv1.2 -fSL --retry $max_retries --retry-delay 2 -H "User-Agent: $UA" "$1"
    elif command -v wget &>/dev/null; then
        wget -qO- --tries=$max_retries --header="User-Agent: $UA" "$1"
    else
        die "Neither curl nor wget found"
    fi
}

dl_to_file() {
    local max_retries=3

    if command -v curl &>/dev/null; then
        curl --proto '=https' --tlsv1.2 -fSL --retry $max_retries --retry-delay 2 -H "User-Agent: $UA" -o "$2" "$1"
    else
        wget -qO "$2" --header="User-Agent: $UA" "$1"
    fi
}

# ---------- YAML parser ----------
# Outputs one "key: value" line per YAML field.
# Strips comments (respecting double-quoted strings) and surrounding quotes.

parse_yaml_apps() {
    awk '
    BEGIN { pending_key = "" }

    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }

    {
        # Strip inline comment (respecting double-quotes)
        line = $0; out = ""; q = 0
        n = split(line, ch, "")
        for (i = 1; i <= n; i++) {
            if (ch[i] == "\"") { q = !q; continue }
            if (ch[i] == "#" && !q) break
            out = out ch[i]
        }
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", out)

        # Strip leading YAML list marker "- "
        sub(/^- /, "", out)

        colon = index(out, ":")
        if (colon == 0) next

        key = substr(out, 1, colon - 1)
        raw = substr(out, colon + 1)
        gsub(/^[[:space:]]+/, "", raw)
        gsub(/[[:space:]]+$/, "", raw)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)

        # Skip root key
        if (key == "github_apps") next
        if (key == "") next

        # Strip surrounding double-quotes
        if (raw ~ /^".*"$/) { raw = substr(raw, 2, length(raw) - 2) }
        if (raw ~ /^'"'"'.*'"'"'$/) { raw = substr(raw, 2, length(raw) - 2) }

        # Prefix key with _ to avoid shadowing shell builtins (e.g. name)
        key = "_" key

        if (raw != "") {
            # Inline value: emit any pending multiline value first
            if (pending_key != "") print pending_key ": "
            print key ": " raw
            pending_key = ""
        } else {
            # No inline value: emit pending, start new accumulation
            if (pending_key != "") print pending_key ": "
            pending_key = key
        }
    }

    END {
        if (pending_key != "") print pending_key ": "
    }
    ' "$YAML_FILE"
}

# ---------- version check ----------

check_version() {
    local bin="$1" ver="$2" varg="${3:---version}"
    local out
    out=$("$bin" "$varg" 2>&1) || return 1
    echo "$out" | grep -qF "$ver"
}

# ---------- install logic ----------

install_app() {
    local name="$1" repo="$2" version="$3"
    local tag_prefix="$4" binary_name="$5" binary_pattern="$6"
    local version_arg="${7:---version}"
    # Default tag_prefix to "v" only when not explicitly set
    [[ "$tag_prefix" == "__DEFAULT__" ]] && tag_prefix="v"

    info "[$name] $version"

    # Already installed?
    if command -v "$binary_name" &>/dev/null && check_version "$binary_name" "$version" "$version_arg"; then
        info "[$name] already installed, skipping"
        return 0
    fi

    # Build tag: strip leading v from version, prepend tag_prefix
    local tag="${tag_prefix}${version#v}"

    # Replace __VERSION__ placeholder in asset pattern
    local asset="${binary_pattern//__VERSION__/$version}"
    local url="https://github.com/$repo/releases/download/$tag/$asset"
    local tmpdir
    tmpdir=$(mktemp -d)

    info "[$name] downloading $asset"
    if ! dl_to_file "$url" "$tmpdir/$asset"; then
        warn "[$name] download failed: $url"
        rm -rf "$tmpdir"
        return 1
    fi

    # Extract or copy
    if [[ "$asset" =~ \.(tar\.gz|tgz|tar\.bz2|zip)$ ]]; then
        local extract_dir="$tmpdir/extract"
        mkdir -p "$extract_dir"

        case "$asset" in
        *.tar.gz | *.tgz) tar -xzf "$tmpdir/$asset" -C "$extract_dir" ;;
        *.tar.bz2) tar -xjf "$tmpdir/$asset" -C "$extract_dir" ;;
        *.zip) unzip -qo "$tmpdir/$asset" -d "$extract_dir" ;;
        esac

        local found
        found=$(find "$extract_dir" -type f -name "$binary_name" | head -1)
        if [[ -z "$found" ]]; then
            warn "[$name] binary '$binary_name' not found in archive, listing contents:"
            find "$extract_dir" -type f | head -10 | while read -r f; do
                warn "  $(basename "$f")"
            done
            rm -rf "$tmpdir"
            return 1
        fi

        cp -af "$found" "$INSTALL_DIR/$binary_name"
        chmod +x "$INSTALL_DIR/$binary_name"
    else
        # Plain binary
        cp -af "$tmpdir/$asset" "$INSTALL_DIR/$binary_name"
        chmod +x "$INSTALL_DIR/$binary_name"
    fi

    rm -rf "$tmpdir"
    info "[$name] installed -> $INSTALL_DIR/$binary_name"
}

# ---------- main ----------

main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -f | --file)
            YAML_FILE="$2"
            shift 2
            ;;
        -d | --dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -h | --help)
            echo "Usage: $0 [-f yaml_file] [-d install_dir]"
            echo "  -f, --file   YAML file (default: roles/github/vars/main.yml)"
            echo "  -d, --dir    Install directory (default: /usr/local/bin)"
            exit 0
            ;;
        *) die "Unknown option: $1" ;;
        esac
    done

    [[ -f "$YAML_FILE" ]] || die "YAML file not found: $YAML_FILE"
    [[ $EUID -ne 0 ]] && die "This script must be run as root (or with sudo)"
    command -v curl &>/dev/null || command -v wget &>/dev/null ||
        die "curl or wget is required"

    mkdir -p "$INSTALL_DIR"

    info "Reading apps from $YAML_FILE"
    info "Install directory: $INSTALL_DIR"

    local count=0
    local _name="" _repo="" _version="" _tag_prefix="v"
    local _binary_name="" _binary_pattern="" _version_arg="--version"

    # Read "key: value" pairs; when _name is already set and a new _name arrives,
    # flush the previous app.
    while IFS= read -r line; do
        local key="${line%%:*}"
        local val="${line#*: }"

        case "$key" in
        _name)
            [[ -n "$_name" ]] && {
                install_app "$_name" "$_repo" "$_version" "$_tag_prefix" "$_binary_name" "$_binary_pattern" "$_version_arg"
                count=$((count + 1))
                _tag_prefix="v"
                _version_arg="--version"
            }
            _name="$val"
            ;;
        _repo) _repo="$val" ;;
        _version) _version="$val" ;;
        _tag_prefix) _tag_prefix="$val" ;;
        _binary_name) _binary_name="$val" ;;
        _binary_pattern) _binary_pattern="$val" ;;
        _version_arg) _version_arg="$val" ;;
        esac
    done < <(parse_yaml_apps)

    # Flush the last app
    if [[ -n "$_name" ]]; then
        install_app "$_name" "$_repo" "$_version" "$_tag_prefix" "$_binary_name" "$_binary_pattern" "$_version_arg"
        count=$((count + 1))
    fi

    info "Done. Processed $count app(s)."
}

main "$@"

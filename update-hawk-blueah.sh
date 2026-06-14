#!/usr/bin/env bash

set -euo pipefail

VERSION=44
IMMUTABLUE_DIR="${IMMUTABLUE_DIR:-${HOME}/Documents/01_Projects_Personal/immutablue}"

# --yes / -y stages the update and reboots without prompting.
ASSUME_YES=0
for arg in "$@"; do
    case "$arg" in
        -y|--yes) ASSUME_YES=1 ;;
        *) echo "Unknown argument: $arg" >&2; exit 1 ;;
    esac
done

# Prompt for a yes/no answer, defaulting to no. Returns success on yes.
# Auto-confirms when --yes was passed.
confirm() {
    if [[ "$ASSUME_YES" -eq 1 ]]; then
        return 0
    fi
    local reply
    read -r -p "$1 [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

# ---------------------------------------------------------------------------
# immutablue-cyan and hawk-blueah aren't built in CI, so rebuild them locally.
# Pull base + deps fresh from the registry first so buildah doesn't resolve
# the FROM lines to stale local layers.
# ---------------------------------------------------------------------------
(
    cd "${IMMUTABLUE_DIR}"
    echo "Updating submodules..."
    git submodule update --init --recursive
    echo "DONE"
    echo "Grabbing updated base container..."
    podman pull "quay.io/immutablue/immutablue:${VERSION}"
    echo "DONE"
    echo "Grabbing updated base deps container..."
    podman pull "quay.io/immutablue/immutablue:${VERSION}-deps"
    echo "DONE"
    echo "Grabbing updated base cyan deps container..."
    podman pull "quay.io/immutablue/immutablue:${VERSION}-cyan-deps"
    echo "DONE"

    echo "Building new cyan image..."
    # SKIP_TEST=1 works around a SC2115 shellcheck false positive on the
    # literal `rm -rf /boot/*` in build/90-post.sh — remove once upstream
    # silences it.
    make CYAN=1 SKIP_TEST=1 build-cyan-deps push-cyan-deps all
    echo "DONE"
)

# Pull the just-pushed cyan tag so the hawk-blueah build picks up the new
# digest rather than whatever was sitting in the local store.
podman pull "quay.io/immutablue/immutablue:${VERSION}-cyan"

# ---------------------------------------------------------------------------
# Build hawk-blueah on top of the freshly-built bases.
# ---------------------------------------------------------------------------
echo "Building new version $VERSION base hawk-blueah..."
make all
echo "DONE"
echo "Building new version $VERSION cyan hawk-blueah..."
make CYAN=1 all
echo "DONE"

echo "Hawk-blueah is up-to-date."
if ! confirm "Ready to stage and apply the changes? (this will reboot)"; then
    echo "Skipping. Reboot into the new image whenever you're ready."
    exit 0
fi

echo "Staging and applying update (system will reboot)..."
sudo bootc update --apply

#!/bin/bash
set -euxo pipefail 
if [ -f "${CUSTOM_INSTALL_DIR}/build/99-common.sh" ]; then source "${CUSTOM_INSTALL_DIR}/build/99-common.sh"; fi
if [ -f "./99-common.sh" ]; then source "./99-common.sh"; fi

# Substitute Fedora version into the os-release template copied from
# artifacts/overrides/etc/os-release so $releasever resolves correctly.
sed -i "s/__FEDORA_VERSION__/${VERSION}/g" /etc/os-release

# tuned-ppd ships in the base image and owns the same dbus files as tlp,
# so it must be removed before tlp can be layered in 30-install-packages.sh.
if rpm -q tuned-ppd >/dev/null 2>&1; then
    rpm-ostree override remove tuned-ppd
fi


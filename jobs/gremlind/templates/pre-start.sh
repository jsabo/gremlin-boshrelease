#!/bin/bash
set -e

INSTALL_USER="<%= p('gremlin.install_user') %>"
INSTALL_GROUP="<%= p('gremlin.install_group') %>"
BIN_MODE="<%= p('gremlin.install_bin_mode') %>"
BIN_CAPS="<%= p('gremlin.install_bin_capabilities') %>"

# 1) Create user/group
getent group "${INSTALL_GROUP}" >/dev/null || groupadd -r "${INSTALL_GROUP}"
getent passwd "${INSTALL_USER}" >/dev/null || \
  useradd -r -g "${INSTALL_GROUP}" -d /var/lib/gremlin \
    -s /sbin/nologin -c "Gremlin Service User" "${INSTALL_USER}"

# 2) Prepare dirs
for d in /etc/gremlin /var/lib/gremlin /var/log/gremlin /var/vcap/sys/run/gremlind; do
  mkdir -p "${d}"
  chown "${INSTALL_USER}:${INSTALL_GROUP}" "${d}"
done

# 3) Apply bin mode & owner
BIN_DIR="/var/vcap/packages/gremlin"
chown root:root "${BIN_DIR}/bin/gremlin" "${BIN_DIR}/bin/gremlin-gpu"
chmod "${BIN_MODE}"   "${BIN_DIR}/bin/gremlin" "${BIN_DIR}/bin/gremlin-gpu"

# 4) Runtime setcap
if [ "${BIN_CAPS}" = "true" ]; then
  if ! command -v setcap &>/dev/null; then
    echo "ERROR: setcap not found; please include libcap2-bin on stemcell" >&2
    exit 1
  fi
  setcap cap_sys_boot,cap_kill,cap_sys_time,cap_net_admin,cap_net_raw+ep \
    "${BIN_DIR}/bin/gremlin"
fi


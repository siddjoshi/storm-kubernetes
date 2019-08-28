#!/bin/bash
set -e
# Allow the container to be started with `--user`
if [ "$1" = 'storm' -a "$(id -u)" = '0' ]; then
    chown -R storm:storm "$STORM_CONF_DIR" "$STORM_DATA_DIR" "$STORM_LOG_DIR"
    exec gosu storm "$0" "$@"
fi
# Generate the config only if it doesn't exist
CONFIG="$STORM_CONF_DIR/storm.yaml"
if [ ! -f "$CONFIG" ]; then
    cat << EOF > "$CONFIG"
storm.zookeeper.servers:
  - "zk-0.zk-hs.default.svc.cluster.local"
  - "zk-1.zk-hs.default.svc.cluster.local"
  - "zk-2.zk-hs.default.svc.cluster.local"
nimbus.seeds: ["nimbus-0.nimbus.default.svc.cluster.local", "nimbus-1.nimbus.default.svc.cluster.local"]
storm.log.dir: "$STORM_LOG_DIR"
storm.local.dir: "$STORM_DATA_DIR"
EOF
fi

exec "$@"


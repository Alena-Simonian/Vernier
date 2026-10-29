#!/bin/sh
# Starts Redis with the dev ACL user and seeds it once it answers. Nothing is
# persisted, so every start seeds afresh; the marker the healthcheck reads is
# written only once the whole seed succeeded, and removed first so a restart
# never looks seeded before it is.
set -eu

MARKER=/tmp/vernier-seeded
rm -f "$MARKER"

(
    CLI="redis-cli --user vernier --pass vernier --no-auth-warning"
    until $CLI ping > /dev/null 2>&1; do
        sleep 0.2
    done
    # `-e` makes a command the server refused fail the whole run.
    grep -v '^#' /vernier-init/seed.redis | $CLI -e > /dev/null
    touch "$MARKER"
) &

exec docker-entrypoint.sh redis-server --save '' --appendonly no \
    --user default off --user vernier on '>vernier' '~*' '&*' '+@all'

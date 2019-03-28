#!/bin/bash
set -e

# Run confd to render config file(s)
CONFD_BACKEND="${CONFD_BACKEND:-env}"

echo "Run confd with backend ${CONFD_BACKEND}"
confd -onetime -backend $CONFD_BACKEND || exit 1

# Grant permissions to /dev/stdout for spawned squid process
chown squid:squid /dev/stdout


mkdir /var/spool/squid
chown squid:squid /var/spool/squid

echo ""
echo "[DEBUG] squid.conf"
cat /etc/squid/squid.conf

echo ""
echo "[DEBUG] whitelist.txt"
cat /etc/squid/whitelist.txt

echo ""
echo "[DEBUG] blacklist.txt"
cat /etc/squid/blacklist.txt
# Run application
exec "$@"
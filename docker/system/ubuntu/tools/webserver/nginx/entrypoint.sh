#!bin/bash
set -e
/setrights.sh
/usr/sbin/nginx -g "daemon off;"
#exec "$@"
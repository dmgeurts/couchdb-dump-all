#!/bin/bash
# Backup all CouchDB databases one by one

# Configuration file expected at
CONFIG=/etc/backup/couchdb-dump-all.conf

# With the following content required:
#
# COUCHDB_USER=admin
# COUCHDB_PASS=password
# HOST=127.0.0.1
# PORT=5984
# BACKUP_PATH="/var/backup/nakivo/couchdb"

# Optional setting(s)
DATE=false
HTTP=http

# Test if config file exists
if [[ ! -f "$CONFIG" ]]; then
    echo "ERROR: config file not found: $CONFIG"
    exit 1
else
    source "$CONFIG"
fi

# Test if all settings are found
if [[ -z "$COUCHDB_USER" || -z "$COUCHDB_PASS" || -z "$HOST" || -z "$PORT" || -z "$BACKUP_PATH" ]]; then
    echo "ERROR: One or more variables missing from config file: $CONFIG"
    exit 1
else
    echo "Config file read successfully."
fi

# Handle optional settings and default values
if [[ "$DATE" == "true" ]]; then
    DATE=".$(date -I)"
else
    DATE=""
fi
if [[ "$HTTP" != "https" ]] && [[ "$HTTP" != "http" ]]; then
    echo "Wrong protocol set, using http."
    HTTP="http"
fi

# Get all DBs (excluding system ones):
ALL_DBS=$(curl -u ${COUCHDB_USER}:${COUCHDB_PASS} $HTTP://$HOST:$PORT/_all_dbs 2>/dev/null | python -m json.tool | awk -F'"' '{print$2}' | grep -v "^_\|^$")

C_DONE=0
C_FAIL=0
# Backup each found DB
for db in $ALL_DBS; do
    echo "Starting backup of: $db"
    db_enc=$(printf %s "$db" | jq -sRr @uri)
    FILE=${db//\//_}
    if STATUS=$(/usr/local/bin/couchdb-dump.sh -b -H $HOST -P $PORT -d $db_enc -f "$BACKUP_PATH/${FILE}${DATE}.json" -u $COUCHDB_USER -p $COUCHDB_PASS) &> /dev/null; then
        ((C_DONE++))
        echo "Finished backup of: $db"
    else
        rm "$BACKUP_PATH/${FILE}${DATE}.json"
        ((C_FAIL++))
        echo "$STATUS"
        printf "ERROR: Backup failed for db: $db\n\n"
    fi
done
if [[ "$C_FAIL" == "0" ]]; then
    FAILED=""
else
    FAILED="Failures: $C_FAIL"
fi
echo "DONE: Backup of $C_DONE databases completed. $FAILED"

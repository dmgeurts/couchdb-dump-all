# couchdb-dump-all

Just a simple wrapper for [couchdb-dump](https://github.com/danielebailo/couchdb-dump) to dump all databases.

## Requirements

In addition to the requirements for `couchdb-dump.sh`: jk 

## Options

No command line arguments, but does read a configuration file. The location of the config file is set to:

`CONFIG=/etc/backup/couchdb-dump-all.conf` 

This file is expected to contain at least these options:

```text
COUCHDB_USER=admin
COUCHDB_PASS=password
HOST=127.0.0.1
PORT=5984
BACKUP_PATH="/var/backup/couchdb"
```

Modify as required. Note, however, that credentials in a URL should only be used on localhost connections. Use at your peril.

Optional settings: 

`DATE=false` - Whether to include the date in the backup filename.
`HTTP=http` - Protocol: http or https? No need to use https when connecting to localhost.
`FAILS=5` - Failure threshold before giving up.

## Installation

The suggested location for both `couchdb-dump(-all).sh` is `/usr/local/bin/`.

#!/bin/sh
[ -n "$RSPAMD" ] && rspamc  -h "$RSPAMD" "$1"

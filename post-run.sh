#!/bin/sh
sleep 1m
echo "Staring indexing of mailboxes..."
DOMS=$(find /var/vmail/mailboxes -type d -maxdepth 1 -mindepth 1 | sed "s+.*/++" | xargs)
for DOM in ${DOMS}; do
  DOVEUSERS=$(find /var/vmail/mailboxes/"$DOM" -type d -maxdepth 1 -mindepth 1 | sed "s+.*/++" | xargs)
  for DUSER in ${DOVEUSERS}; do
    EXCLUDES=$(doveconf -n | grep autoindex_exclude | sed -e "s/.*=\s//g" -e "s/[\\]//g" | xargs)
    MAILBOXES=$(doveadm mailbox list -u "$DUSER@$DOM" | xargs)
    for BOX in ${MAILBOXES}; do
      INDX="yes"
      for EX in ${EXCLUDES}; do
        [ "$EX" != "$BOX" ] || INDX=""
      done
      [ -n "$INDX" ] && doveadm index -u "$DUSER@$DOM" -q "$BOX"
    done
  done
done
sleep 1m
echo "Generating 4096bit dhparam key"
openssl dhparam 4096 >/etc/ssl/dh4096.pem
sed -i 's+ssl_dh=<\/etc\/ssl\/dh2048.pem+ssl_dh=<\/etc\/ssl\/dh4096.pem+g' /etc/dovecot/conf.d/10-ssl.conf
doveadm reload

TH="$(date '+%H')"
sleep "$(echo 23-"$TH"+2 | bc)h"
while true; do
  DOMS=$(find /var/vmail/mailboxes -type d -maxdepth 1 -mindepth 1 | sed "s+.*/++" | xargs)
  for DOM in ${DOMS}; do
    DOVEUSERS=$(find /var/vmail/mailboxes/"$DOM" -type d -maxdepth 1 -mindepth 1 | sed "s+.*/++" | xargs)
    for DUSER in ${DOVEUSERS}; do
      doveadm fts optimize -u "$DUSER@$DOM" 2>&1
    done
  done
  sleep 12h
done

#!/bin/sh
#display environment variables passed with --env
echo "Starting dovecot at $(date +'%x %X')"
echo '$REDIS=' $REDIS
echo '$HOSTNAME=' $HOSTANAME
echo '$LETSENCRPT=' $LETSENCRYPT
echo '$RSPAMD=' $RSPAMD
echo '$GOOGLEPORT=' $GOOGLEPORT
echo

[ -z "$REDIS" ] && echo '$REDIS is not set, needed for auth' && exit 1

NME="dovecot-xapian"
set-timezone.sh "$NME"

cd /etc/dovecot

if [ -n "$REDIS" ]
then
  REDISIP=$(ping -c1 $REDIS | head -n1 | cut -f2 -d'(' | cut -f1 -d')')
# sed  -i "1i uri = redis:host=$REDISIP" dovecot-dict-auth.conf
  echo "uri = redis:host=$REDISIP" > dict.uri
  echo "plugin {
  quota = dict:User quota::redis:host=$REDISIP:prefix=user/
}
" > conf.d/quota.uri
fi

echo "#10-auto.conf from environment variables" > conf.d/10-auto.conf
if [ -n "$HOSTNAME" ]
then
  echo "hostname = $HOSTNAME" >> conf.d/10-auto.conf
  if [ -n "$LETSENCRYPT" ]
  then
    echo "ssl_cert = </etc/letsencrypt/live/$LETSENCRYPT/cert.pem" >> conf.d/10-auto.conf
    echo "ssl_key = </etc/letsencrypt/live/$LETSENCRYPT/privkey.pem" >> conf.d/10-auto.conf
  fi
fi

if [ -n "$PLAINIMAP" ]
then
echo "service imap {" >> conf.d/10-auto.conf
echo "  inet_listener imap-login {" >> conf.d/10-auto.conf
echo "  }" >> conf.d/10-auto.conf
echo "}" >> conf.d/10-auto.conf
fi

if [ -n "$GOGLEPORT" ]
then
  echo "service pop3d {" >> conf.d/10-auto.conf
   echo "inet_listener pop3s-google {" >> conf.d/10-auto.conf
   echo " port = 2221" >> conf.d/10-auto.conf
   echo " ssl = yes" >> conf.d/10-auto.conf
   echo " }" >> conf.d/10-auto.conf
   echo "}" >> conf.d/10-auto.conf
fi

openssl dhparam 2048 > /etc/ssl/dh2048.pem

post-run.sh &

chown 5000:5000 /var/vmail/mailboxes  && chmod 770 /var/vmail/mailboxes

dovecot -F

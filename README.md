# docker-dovecot-xapian
Dockerfile to run [dovecot](https://www.dovecot.org) as a docker container, redis is used for userdb/passdb lookups to reduce footprint.

[![Docker Pulls](https://img.shields.io/docker/pulls/a16bitsysop/dovecot-xapian.svg?style=flat-square)](https://hub.docker.com/r/a16bitsysop/dovecot-xapian/)
[![Docker Stars](https://img.shields.io/docker/stars/a16bitsysop/dovecot-xapian.svg?style=flat-square)](https://hub.docker.com/r/a16bitsysop/dovecot-xapian/)
[![](https://images.microbadger.com/badges/version/a16bitsysop/docevot-xapian.svg)](https://microbadger.com/images/a16bitsysop/dovecot-xapian "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/a16bitsysop/dovecot-xapian.svg)](https://microbadger.com/images/a16bitsysop/dovecot-xapian "Get your own commit badge on microbadger.com")

It uses inet lmtp with ssl and auth, instead of sockets as running inside docker network and reduces dependencies.

fts-xapian is used for full text search as it will replace fts-squat.

The default storage quota is 20GB per user, quota settings can be changed with userdb extra fields see [redis keys](#redis-keys).

Mailboxes are stored in dovecot's sdbox format at /var/vmail/mailboxes, so persistent storage should be mounted there to keep the email.

## To import email into docker-dovecot-xapian
### On old dovecot machine
* Create a user for the reverse tunnel: ```sudo useradd SSHTUNUSER -m -s /bin/true```
* Set a password: ```sudo passwd SSHTUNUSER```
* Edit /etc/ssh/sshd_config to disable login and allow tunnel:
```
  Match User SSHTUNUSER
  PermitOpen 127.0.0.1:2222
  X11Forwarding no
  AllowAgentForwarding no
  ForceCommand /bin/false
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```
* Reload ssh: ```sudo service sshd reload```

### Redis
* First [create redis keys](#redis-keys) in the redis server container for each user
* To create a new password inside docker-dovecot-xapian run ```doveadm pw```
* Copy the password hash and create key in redis container with it, $ in password needs escaping with \ as well.

### Inside docker-dovecot-xapian
* Change password for doveback user: ```passwd doveback```
* Start dropbear ssh server in background: ```dropbear -R -E -p 127.0.0.1:22```
* Start reverse ssh tunnel to old dovecot machine: ```ssh -R 2222:localhost:22 -N SSHTUNUSER@OLDDOVCOTIP```

### On old dovecot machine
* Sync mail into docker-dovecot-xapian with the tunnel:
```sudo doveadm backup -u USERNAME@THISSERVER ssh doveback@127.0.0.1 -p 2222 -o "UserKnownHostsFile /dev/null" doas doveadm dsync-server -u REMOTEUSER@REMOTESERVER```
* doveadm backup is one way doveadm sync is two way
* USERNAME@THISSERVER and REMOTEUSER@REMOTESERVER would be the same unless THISSERVER does not use virtual mailboxes
* Repeat for each mailbox that is being migrated or use a script like:
```
#!/bin/sh
allusers="user1@ex.com user2@ex.com user3@ex.com user4@ex.com"
sshcmd="ssh doveback@127.0.0.1 -p 2222 -o \"UserKnownHostsFile /dev/null\""
echo "Syncing Mail..."
for usname in ${allusers}; do
  echo "Syncing $usname"
  sudo doveadm backup -u $usname $sshcmd doas doveadm dsync-server -u $usname
done
```
### Inside docker-dovecot-xapian
* List processes: ```ps -A```
* kill ssh and dropbear processes: 
```
kill -SIGTERM DROPBEARPID
kill -SIGTERM SSHPID
```

## Redis Keys
The following redis keys need setting for each user

| KEY                          | Description                                                                         | Example                                                                             |
| ---------------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| userdb/user@example.com      | Username exists check, and json string of userdb fields                             | redis-cli set userdb/user@example.com {}<br>or unlimited storage<br> redis-cli set "userdb/user@example" {\\"quota_rule\\":\\"*:storage=0\\"}                                           |
| passdb/user@example.com      | Json user password hash string, hash can be copied from shadow                      | redis-cli set passdb/user@example.com {\\"password\\":\\"{CRYPT}$6$MOREPASSWORDHASH\\"}|

## Github
Github Repository: [https://github.com/a16bitsysop/docker-dovecot-xapian](https://github.com/a16bitsysop/docker-dovecot-xapian)

## Environment Variables

| NAME        | Description                                                               | Default               |
| ----------- | ------------------------------------------------------------------------- | --------------------- | 
| REDIS       | Name/container name or IP of the redis server                             | none                  |
| HOSTNAME    | Hostname for dovecot to use                                               | none                  |
| LETSENCRYPT | Folder name for ssl certs (/etc/letsencrypt/live/$LETSENCRYPT/cert.pem)   | none                  |
| PLAINIMAP   | Listen on port 143 for imap without ssl (for testing)                     | do not use plain imap |
| GOOGLEPORT  | Listen for pop3s on 2221                                                  | do not use this port  |
| RSPAMD      | Name/container name or IP of rspamd, for learn ham/spam                   | none                  |
| TIMEZONE    | Timezone to use inside the container, eg Europe/London                    | unset                 |

## Examples
To run connecting to container network exposing ports (accessible from host network), and docker managed volumes
```
#docker container run -p 993:993 -p 995:995 --name dovecot --restart=unless-stopped --mount source=dovecot-var,target=/var/lib/dovecot --mount source=dovecot-mail,target=/var/vmail/mailboxes -d a16bitsysop/dovecot-xapian
```

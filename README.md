# docker-rspamd
Dockerfile to run [dovecot](https://www.dovecot.org) as a docker container, redis is used instead of the usual mariaDB for user data lookups to reduce footprint.

[![Docker Pulls](https://img.shields.io/docker/pulls/a16bitsysop/dovecot-xapian.svg?style=flat-square)](https://hub.docker.com/r/a16bitsysop/dovecot-xapian/)
[![Docker Stars](https://img.shields.io/docker/stars/a16bitsysop/dovecot-xapian.svg?style=flat-square)](https://hub.docker.com/r/a16bitsysop/dovecot-xapian/)
[![](https://images.microbadger.com/badges/version/a16bitsysop/docevot-xapian.svg)](https://microbadger.com/images/a16bitsysop/dovecot-xapian "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/a16bitsysop/dovecot-xapian.svg)](https://microbadger.com/images/a16bitsysop/dovecot-xapian "Get your own commit badge on microbadger.com")

It uses network lmtp and auth, instead of sockets as running inside docker and reduces dependencies.

fts-xapian is used for full text search as it will replace fts-squat.

## Redis Keys
The following redis keys need setting for each user

| KEY                          | Description                                                                         | Example                                                                             |
| ---------------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| userdb/USERNAME              | Username exists check, and json string of userdb fields                             | redis-cli set userdb/user@example.com {}                                            |
| user/USERNAME/quota/messages | Quota limit in number of messages, 0 means unlimited (90-quota.conf and quota.uri). | redis-cli set user/user@example.com/quota/messages 0                                |
| user/USERNAME/quota/storage  | Quota limit in kilobytes, 0 means unlimited (90-quota.conf and quota.uri).          | redis-cli set user/user@example.com/quota/storage 0                                 |
| passdb/USERNAME              | Json user password hash string, hash can be copied from shadow                      | redis-cli set passdb/user@example.com {\\"password\\":\\"{CRYPT}$6$MOREPASSWORDHASH\\"}|

## Github
Github Repository: [https://github.com/a16bitsysop/docker-rspamd](https://github.com/a16bitsysop/docker-rspamd)

## Environment Variables

| NAME        | Description                                                               | Default               |
| ----------- | ------------------------------------------------------------------------- | --------------------- | 
| REDIS       | Name/container name or IP of the redis server                             | none (No redis)       |
| HOSTNAME    | Hostname for dovecot to use                                               | none                  |
| LETSENCRYPT | Folder name for ssl certs (/etc/letsencrypt/live/$LETSENCRYPT/cert.pem)   | none                  |
| PLAINIMAP   | Listen on port 143 for imap without ssl (for testing)                     | do not use plain imap |
| GOOGLEPORT  | Listen for pop3 on 2221                                                   | do not use this port  |
| RSPAMD      | Name/container name or IP of rspamd, for learn ham/spam                   | none                  |
| TIMEZONE    | Timezone to use inside the container, eg Europe/London                    | unset                 |

## Examples
To run connecting to container network exposing ports (accessible from host network), and docker managed volumes
```
#docker container run -p 993:993 -p 995:995 --name dovecot --restart=unless-stopped --mount source=dovecot-var,target=/var/lib/dovecot --mount source=dovecot-mail,target=/var/vmail/mailboxes -d a16bitsysop/dovecot-xapian
```

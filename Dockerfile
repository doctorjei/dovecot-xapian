FROM alpine:3.12
LABEL maintainer "Duncan Bellamy <dunk@denkimushi.com>"

RUN sed -i -e 's/v[[:digit:]]\..*\//edge\//g' /etc/apk/repositories \
&& apk add --no-cache dovecot-lmtpd dovecot-pop3d dovecot-pigeonhole-plugin \
 rspamd-client dropbear dropbear-ssh doas \
&& apk add dovecot-fts-xapian --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
&& rm -rf /etc/dovecot/conf.d/* \
&& mkdir /var/vmail /etc/dropbear \
&& addgroup -S -g 5000 vmail && adduser -S -u 5000 -h /var/vmail/mailboxes --gecos "virtual mailbox user" --ingroup vmail vmail \
&& adduser -D -h /home/doveback doveback \
&& echo "doveback:$(openssl rand -base64 32)" | chpasswd \
&& echo "permit nopass doveback as root cmd doveadm" >> /etc/doas.conf

COPY --chown=vmail:vmail sieve /var/vmail/sieve

WORKDIR /etc/dovecot
COPY conf ./

WORKDIR /usr/local/bin
COPY travis-helpers/set-timezone.sh entrypoint.sh post-run.sh ./
ENTRYPOINT [ "entrypoint.sh" ]

EXPOSE 993 995 2221
VOLUME [ "/var/lib/dovecot" "/var/vmail/mailboxes" ]

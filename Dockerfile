ARG DVER=latest
FROM docker.io/alpine:$DVER
LABEL maintainer="Duncan Bellamy <dunk@denkimushi.com>"
ARG APKVER

ENV PUID=5000 \
    PGID=5000 \
    HOME=/var/vmail/mailboxes

COPY --chmod=755 --chown=vmail:vmail sieve /var/vmail/sieve/global
    
RUN addgroup -S -g ${PGID} vmail \
&& adduser -S -u ${PUID} -h ${HOME} --gecos "virtual mailbox user" --ingroup vmail vmail \
&& mkdir  /var/vmail/sieve/bin

SHELL [ "/bin/ash", "-o", "pipefail", "-c" ]

RUN apk update \
&& apk upgrade --available --no-cache \
&& apk add -u --no-cache curl doas dovecot-lmtpd dovecot-pop3d dovecot-pigeonhole-plugin dovecot-fts-xapian$APKVER \
  dropbear dropbear-ssh icu-data-full stunnel \
  unzip mupdf-tools \
&& mv /usr/bin/curl /var/vmail/sieve/bin/ \
&& rm -rf /etc/dovecot/conf.d/* \
&& adduser -D -h /home/doveback doveback \
&& echo "doveback:$(openssl rand -base64 32)" | chpasswd \
&& echo "permit nopass doveback as root cmd doveadm" >> /etc/doas.conf

WORKDIR /usr/libexec/dovecot
COPY --chmod=755 decode2text.sh ./

WORKDIR /etc/dovecot
COPY conf ./
RUN find /var/vmail/sieve/global -name "*.sieve" -print -exec sievec {} \;

WORKDIR /usr/local/bin
COPY --chmod=755 container-scripts/set-timezone.sh container-scripts/health-nc.sh entrypoint.sh post-run.sh escape-pw.sh ./
CMD [ "entrypoint.sh" ]

COPY --chmod=644 stunnel.conf /etc/stunnel/stunnel.conf

EXPOSE 993 995 2221
VOLUME [ "/var/lib/dovecot" ${HOME} ]

HEALTHCHECK --start-period=60s CMD health-nc.sh PING 5001 PONG || exit 1

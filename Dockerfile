ARG DVER=latest
FROM docker.io/alpine:$DVER
LABEL maintainer="Duncan Bellamy <dunk@denkimushi.com>"
ARG DAPK
ARG APKVER

COPY --chmod=755 --chown=vmail:vmail sieve /var/vmail/sieve/global
RUN addgroup -S -g 5000 vmail \
&& adduser -S -u 5000 -h /var/vmail/mailboxes --gecos "virtual mailbox user" --ingroup vmail vmail \
&& mkdir  /var/vmail/sieve/bin

SHELL [ "/bin/ash", "-o", "pipefail", "-c" ]

RUN apk update \
&& apk upgrade --available --no-cache \
&& apk add -u --no-cache curl doas dovecot-lmtpd dovecot-pop3d dovecot-pigeonhole-plugin dovecot-fts-xapian$APKVER \
  dropbear dropbear-ssh icu-data-full stunnel \
  unzip mupdf-tools \
&& mv /usr/bin/curl /var/vmail/sieve/bin/ \
&& rm -rf /etc/dovecot/conf.d/* \
&& mkdir /etc/dropbear \
&& adduser -D -h /home/doveback doveback \
&& echo "doveback:$(openssl rand -base64 32)" | chpasswd \
&& echo "permit nopass doveback as root cmd doveadm" >> /etc/doas.conf

# if DAPK is not set bake file defaults it to alpine-base
RUN echo "DAPK is: $DAPK" \
&& apk list -q $DAPK | awk '{print $1}'> /etc/apkvers \
&& cat /etc/apkvers

WORKDIR /usr/libexec/dovecot
COPY --chmod=755 decode2text.sh ./

WORKDIR /etc/dovecot
COPY conf ./
RUN find /var/vmail/sieve/global -name "*.sieve" -print -exec sievec {} \;

WORKDIR /usr/local/bin
COPY --chmod=755 container-scripts/set-timezone.sh container-scripts/health-nc.sh entrypoint.sh post-run.sh ./
CMD [ "entrypoint.sh" ]

COPY --chmod=644 stunnel.conf /etc/stunnel/stunnel.conf

EXPOSE 993 995 2221
VOLUME [ "/var/lib/dovecot" "/var/vmail/mailboxes" ]

HEALTHCHECK --start-period=60s CMD health-nc.sh PING 5001 PONG || exit 1

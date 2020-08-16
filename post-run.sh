#!/bin/sh

sleep 2m
openssl dhparam 4096 > /etc/ssl/dh4096.pem
sed -i 's+ssl_dh=<\/etc\/ssl\/dh2048.pem+ssl_dh=<\/etc\/ssl\/dh4096.pem+g' /etc/dovecot/conf.d/10-ssl.conf
doveadm reload

require ["vnd.dovecot.pipe", "copy", "imapsieve"];
pipe :copy "rspamc" [ "-h", "rspamd", "learn_spam" ];

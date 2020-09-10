require ["vnd.dovecot.pipe", "copy", "imapsieve"];
pipe :copy "rspamc" [ "-h", "localhost", "learn_spam" ];

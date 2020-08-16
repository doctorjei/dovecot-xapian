require ["vnd.dovecot.pipe", "copy", "imapsieve"];
pipe :copy "call_rspamc.sh" [ "learn_spam" ];

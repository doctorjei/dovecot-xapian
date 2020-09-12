#!/bin/sh
allusers="user1@ex.com user2@ex.com user3@ex.com user4@ex.com"
sshcmd="ssh doveback@127.0.0.1 -p 2222 -o \"UserKnownHostsFile /dev/null\""
echo "Syncing Mail..."
for usname in ${allusers}; do
  echo "Syncing $usname"
  sudo doveadm backup -u $usname $sshcmd doas doveadm dsync-server -u $usname
done

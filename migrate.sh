#!/bin/sh
# example migration/syncing script

allusers="user1@ex.com user2@ex.com user3@ex.com user4@ex.com"
sshcmd="ssh doveback@127.0.0.1 -o \"UserKnownHostsFile /dev/null\" -p 2222"
echo "Syncing Mail..."
for usname in ${allusers}; do
  echo "Backing up $usname"
  sudo doveadm backup -u "$usname" "$sshcmd" doas doveadm dsync-server -u "$usname"
  #  echo "Syncing up $usname"
  #  sudo doveadm sync -u $usname $sshcmd doas doveadm dsync-server -u $usname
done

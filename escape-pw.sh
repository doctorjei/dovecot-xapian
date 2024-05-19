#!/bin/ash

printf "Enter Password: "read -s _pw1
printf "\nEnter Password Again: "
read -s _pw2

echo
if [ "$_pw1" != "$_pw2" ]; then
  echo "Passwords do not match"
  exit 1
fi

_hash="$(doveadm pw -s ARGON2ID -p ${_pw1})"
echo "Got hash: $_hash"
_hash=${_hash//\$/\\$}
_escape='"{\"password\":\"'"$_hash"'\"}"'
echo "Escaped Hash:"
echo "$_escape"

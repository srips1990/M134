#!/bin/bash

source yobichain.conf

count=$1

if [ $# -gt 1 ]; then
	usernameprefix=$2
fi


# Prevent users from viewing other users' processes
mount -o remount,rw,hidepid=2 /proc

cp ~/$linux_users_credentials_file ~/$linux_users_credentials_file'.bak' 2>/dev/null || :
rm -f ~/$linux_users_credentials_file

for (( i=1; i<=$count; i++ ))
do
   bash -e master.sh $usernameprefix$((i**2)) $i
done

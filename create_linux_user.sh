#!/bin/bash

source yobichain.conf

linux_user=$1

if ! id $linux_user >/dev/null 2>&1; then
	# Setting up user account
	echo '----------------------------------------'
	echo -e 'SETTING UP '$linux_user' USER ACCOUNT:'
	echo '----------------------------------------'

	passwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c40; echo`
	useradd -d /home/$linux_user -s /bin/bash -m $linux_user
	# usermod -a -G $linux_user
	echo $linux_user":"$passwd | chpasswd
	# echo "$linux_user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

homedir=`su -l $linux_user -c 'echo ~'`

chown -R $linux_user: $homedir

cat <<EOT >> ~/$linux_users_credentials_file

user=$linux_user
passwd=$passwd

EOT
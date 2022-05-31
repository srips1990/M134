#!/bin/bash

source yobichain.conf

rpcuser=`< /dev/urandom tr -dc A-Za-z0-9 | head -c15; echo`
rpcpassword=`< /dev/urandom tr -dc A-Za-z0-9 | head -c20; echo`

if [ $# -gt 1 ]; then
	chainname=$1
    linux_admin_user=$2
else
	echo "Missing Parameter!!"
	exit
fi

## CREATING A NEW LINUX USER
bash -e create_linux_admin_user.sh
homedir=`su -l $linux_admin_user -c 'echo ~'`

## SETTING THE PATH OF THE OUTPUT FILE WHICH WOULD CONTAIN YOBICHAIN RELATED CREDENTIALS
outputfilepath=$homedir/$output_file_name
cat > $outputfilepath.tmp << EOF

--------------------------------------------
API CREDENTIALS
--------------------------------------------
rpcuser=$rpcuser
rpcpassword=$rpcpassword

EOF

bash -e core.sh $chainname $rpcuser $rpcpassword $linux_admin_user
# bash -e reg_startup_script.sh $chainname

rm -rf $outputfilepath
cp $outputfilepath.tmp $outputfilepath
rm -f $outputfilepath.tmp
cat $outputfilepath
sudo chown $linux_admin_user: $outputfilepath
 
echo ''
echo ''

echo -e '========================================'
echo -e 'SET UP COMPLETED SUCCESSFULLY!'
echo -e '========================================'
echo ''
echo ''
echo ''
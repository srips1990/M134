#!/bin/bash

source yobichain.conf

rpcuser=`< /dev/urandom tr -dc A-Za-z0-9 | head -c15; echo`
rpcpassword=`< /dev/urandom tr -dc A-Za-z0-9 | head -c20; echo`
iter=1

if [ $# -gt 0 ]; then
    linux_user=$1
else
	echo "Missing Parameter!!"
	exit
fi

if [ $# -gt 1 ]; then
	iter=$(( $2 ))
fi


echo -e '-----------------------'
echo -e 'Creating Linux User...!'
echo -e '-----------------------'
echo ''
## CREATING A NEW LINUX USER
bash -e create_linux_user.sh $linux_user
homedir=`su -l $linux_user -c 'echo ~'`

## SETTING THE PATH OF THE OUTPUT FILE WHICH WOULD CONTAIN YOBICHAIN RELATED CREDENTIALS
outputfilepath=$homedir/$output_file_name
echo -e '-----------------------'
echo -e "Creating $outputfilepath.tmp...!"
echo -e '-----------------------'
echo ''
cat > $outputfilepath.tmp << EOF

--------------------------------------------
API CREDENTIALS
--------------------------------------------
rpcuser=$rpcuser
rpcpassword=$rpcpassword

EOF

bash -e core.sh $chainname $rpcuser $rpcpassword $linux_user $iter

if [ $iter -eq 1 ]; then
	bash -e webserver.sh
fi
# bash -e reg_startup_script.sh $chainname

rm -rf $outputfilepath
cp $outputfilepath.tmp $outputfilepath
rm -f $outputfilepath.tmp
cat $outputfilepath
chown $linux_user: $outputfilepath
 
echo ''
echo ''

echo -e '========================================'
echo -e 'SET UP COMPLETED SUCCESSFULLY!'
echo -e '========================================'
echo ''
echo ''
echo ''
#!/bin/bash

INSTALLER_PATH_RELATIVE="`dirname \"$0\"`"
INSTALLER_PATH="`( cd \"$INSTALLER_PATH_RELATIVE\" && pwd )`"

# echo -e 'Check1...!'
# echo -e '-----------------------'
# echo ''

source yobichain.conf

chainname=$1
rpcuser=$2
rpcpassword=$3
linux_user=$4
iter=1

if [ $# -gt 4 ]; then
	iter=$(( $5 ))
fi

networkport=$(( networkport + iter ))
rpcport=$(( rpcport + iter ))

homedir=`su -l $linux_user -c 'cd ~ && pwd'`
chaindir=$homedir/.multichain/$chainname
# mc_pid=$(pidof -x $(basename multichaind))

echo '----------------------------------------'
echo -e 'PREPARING NODE'$iter'...'
echo '----------------------------------------'
echo ''
echo ''
echo ''
echo '----------------------------------------'
echo -e 'INSTALLING PREREQUISITES...'
echo '----------------------------------------'

cd .. 

if [ $iter -eq 1 ]; then
	add-apt-repository universe
	apt-get --assume-yes update
	apt-get --assume-yes install jq aptitude python3 pip python3-dev gcc

	echo ''
	echo ''
	echo '----------------------------------------'
	echo ''
	echo ''
	echo ''
	echo ''
fi

echo '----------------------------------------'
echo -e 'CONFIGURING FIREWALL.....'
echo '----------------------------------------'

ufw allow $networkport
ufw allow $rpcport
ufw allow 21

echo ''
echo ''
echo '----------------------------------------'
echo ''
echo ''
echo ''
echo ''

echo -e '----------------------------------------'
echo -e 'FIREWALL SUCCESSFULLY CONFIGURED!'
echo -e '----------------------------------------'

if [ ! -f $multichain_install_dir/multichaind ]; then

	echo '----------------------------------------'
	echo -e 'INSTALLING & CONFIGURING MULTICHAIN.....'
	echo '----------------------------------------'
	
	# wget --no-verbose $mc_dl_base_url/multichain-$multichainVersion.tar.gz
	wget $mc_dl_base_url/multichain-$multichainVersion.tar.gz
	bash -c 'tar xvf multichain-'$multichainVersion'.tar.gz'
	bash -c 'cp multichain-'$multichainVersion'*/multichain* '$multichain_install_dir'/'
fi


if [ -d $chaindir ]; then
	# echo -e 'Stopping existing processes if any...'
	# echo ''
	# echo ''
	# su -l $linux_user -c 'multichain-cli '$chainname' stop >/dev/null 2>&1'
	echo -e 'Removing the existing chain directory...'
	echo ''
	echo ''
	rm -rf $chaindir
fi

su -l $linux_user -c 'cd ~ && pwd'
su -l $linux_user -c  'multichain-util create '$chainname' '$protocol''

su -l $linux_user -c "sed -i 's/.*root-stream-open =.*\#/root-stream-open = false     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*mining-requires-peers =.*\#/mining-requires-peers = true     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*initial-block-reward =.*\#/initial-block-reward = 0     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*first-block-reward =.*\#/first-block-reward = -1     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*skip-pow-check =.*\#/skip-pow-check = true     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*target-adjust-freq =.*\#/target-adjust-freq = -1     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*max-std-tx-size =.*\#/max-std-tx-size = 100000000     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*max-std-op-returns-count =.*\#/max-std-op-returns-count = 1024     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*max-std-op-return-size =.*\#/max-std-op-return-size = 8388608     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*max-std-op-drops-count =.*\#/max-std-op-drops-count = 100     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*max-std-element-size =.*\#/max-std-element-size = 32768     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*default-network-port =.*\#/default-network-port = '$networkport'     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*default-rpc-port =.*\#/default-rpc-port = '$rpcport'     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c "sed -i 's/.*chain-name =.*\#/chain-name = '$chainname'     #/g' $homedir/.multichain/$chainname/params.dat"
su -l $linux_user -c " sed -i 's/.*protocol-version =.*\#/protocol-version = '$protocol'     #/g' $homedir/.multichain/$chainname/params.dat"

su -l $linux_user -c "echo rpcuser='$rpcuser' > $homedir/.multichain/$chainname/multichain.conf"
su -l $linux_user -c "echo rpcpassword='$rpcpassword' >> $homedir/.multichain/$chainname/multichain.conf"
su -l $linux_user -c 'echo rpcport='$rpcport' >> '$homedir'/.multichain/'$chainname'/multichain.conf'

echo ''
echo ''
echo '----------------------------------------'
echo ''
echo ''
echo ''
echo ''

echo '----------------------------------------'
echo -e 'RUNNING BLOCKCHAIN.....'
echo '----------------------------------------'

su -l $linux_user -c 'multichaind '$chainname' -daemon -explorersupport=2'

echo ''
echo ''
echo '----------------------------------------'
echo ''
echo ''
echo ''
echo ''

echo '----------------------------------------'
echo -e 'LOADING CONFIGURATION.....'
echo '----------------------------------------'

sleep 6

addr=`curl --user $rpcuser:$rpcpassword --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getaddresses", "params": [] }' -H 'content-type: text/json;' http://127.0.0.1:$rpcport | jq -r '.result[0]'`


echo ''
echo ''
echo '----------------------------------------'
echo ''
echo ''
echo ''
echo ''

echo -e '----------------------------------------'
echo -e 'BLOCKCHAIN SUCCESSFULLY SET UP!'
echo -e '----------------------------------------'
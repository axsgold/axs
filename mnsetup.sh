#!/bin/bash


DAEMON_URL=https://github.com/axsgold/axs/releases/download/v2.0.0.1-FORK/axsd-precompiled-daemon-v2.zip
DAEMON_FILE=axsd-precompiled-daemon-v2.zip

function prepare_swap() {
	if free | awk '/^Swap:/ {exit !$2}'; then
		printf "\nSwap exists\n\n"
	else
		dd if=/dev/zero of=/swapfile count=2048 bs=1M
		chmod 600 /swapfile
		mkswap /swapfile
		swapon /swapfile
		echo "/swapfile none swap sw 0 0" >> /etc/fstab
	fi
}

function update_system() {
	apt-get -yqq update
}

function install_packages() {
apt-get -yqq install libdb5.3++ \
libboost-all-dev \
unzip \
pwgen \
libminiupnpc-dev

add-apt-repository -y ppa:bitcoin/bitcoin
apt-get -yqq update
apt-get -yqq install libdb4.8-dev libdb4.8++-dev

}

#***************************** main *********************************************************

cat << "AXS"

AXS

# Check for root

if [ "$(whoami)" != "root" ] && [ "$(whoami)" != "pi" ]
then
  echo "Script must be run as user: root"
  exit -1
fi

cat << "INFO"
This script will install and configure AXS (AXS) masternode daemon.

Fresh Ubuntu 16.04 installation required. Tested on Vultr vps.

You should have already transfered 5000 AXS collateral to freshly created address.

Please launch your AXS wallet, and navigate to HELP->DEBUG WINDOW->CONSOLE.
Issue the first command and confirm with ENTER:

masternode genkey

results should look like this: nBvUsZqd\vp6q6dHQZRtNpM7143BwkvyshEU9TPYcrm5himYF5M
it is your masternode KEY.

Issue the second command and confirm with ENTER:

masternode outputs

results should look like this:

{
    "8a261489b2121d5923df8ea2b4554203491a87a54fc7b58d88019e95684315c7" : "0"
}

characters in first pair of brackets: 8a261489b2121d5923df8ea2b4554203491a87a54fc7b58d88019e95684315c7 are your TXID
the number in second pair of brackets: 0 is your TXO

Keep the wallet open. You will need this data later on.
Script will ask you for KEY, TXID and TXO. Just copy / paste from your wallet debug window.

Press ENTER when ready...
INFO

read

echo
echo

# Download and prepare precompiled daemon

echo "Enabling SWAP if not present"
echo 
prepare_swap

echo "Downloading updates and requires packages"
echo
update_system
install_packages

echo "Downloading precompiled binaries"
echo 

wget -q $DAEMON_URL
cd /root
unzip -qq $DAEMON_FILE

# Create config
rm -rf /root/.axs
mkdir .axs

PASS="$(pwgen -1 -s 44)"

echo

IP="$(wget -qO- -o- ipinfo.io/ip)"
read -e -i "$IP" -p "Confirm masternode IPv4 Address: " input
IP="${input:-$IP}"

PORT=33771
read -e -i "$PORT" -p "Confirm masternode port: " input
PORT="${input:-$PORT}"

KEY=''
read -e -i "$KEY" -p "Enter masternode KEY: " input
KEY="${input:-$KEY}"
read -e -i "$KEY" -p "Confirm masternode KEY: " input
KEY="${input:-$KEY}"
echo
TXID=''
read -e -i "$TXID" -p "Enter TXID: " input
TXID="${input:-$TXID}"
read -e -i "$TXID" -p "Confirm TXID: " input
TXID="${input:-$TXID}"
echo
TXO=''
read -e -i "$TXO" -p "Enter TXO: " input
TXO="${input:-$TXO}"
read -e -i "$TXO" -p "Confirm TXO: " input
TXO="${input:-$TXO}"
echo
printf "rpcuser=AXSrpc
rpcpassword=$PASS
server=1
listen=1
daemon=1
staking=0
masternode=1
masternodeaddr=$IP:33771
masternodeprivkey=$KEY\n" > /root/.axs/axs.conf
addnode=209.250.251.252:33771
addnode=217.69.0.8:33771
addnode=209.250.239.117:33771
addnode=45.76.133.189:33771
addnode=207.148.115.228:33771
addnode=45.63.124.201:33771
addnode=66.42.34.104:33771
addnode=108.160.131.220:33771
addnode=149.28.29.172:33771
addnode=45.32.13.142:33771
addnode=149.28.31.61:33771
addnode=45.77.25.10:33771
addnode=207.148.106.155:33771

MNCONF="MN1 "$IP":"$PORT" "$KEY" "$TXID" "$TXO

echo "Creating AXS.conf file"
echo

echo "Your AXS masternode is ready to go!"
echo "Type ./axsd to run it"
echo
echo "Now on the PC with AXS wallet open the wallet directory. On Windows it's: %appdata%/wallet"
echo "check if masternode.conf file exists. If yes, edit it with Notepad. If not - just create empty masternode.conf file.
You want it to contain only the line below:"
echo
echo $MNCONF
echo
echo "Save the masternode.conf file, restart your wallet. On Masternodes tab press update."
echo
echo "Your MN1 should appear on the list. Press Start."
echo
echo "Make sure your wallet is UNLOCKED before pressing start!"
echo
echo "CONGRATULATIONS! Your AXS masternode is up and running!"

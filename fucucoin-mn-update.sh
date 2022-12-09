#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'fucucoind' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop fucucoind${NC}"
        fucucoin-cli stop
        sleep 30
        if pgrep -x 'fucucoind' > /dev/null; then
            echo -e "${RED}fucucoind daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 fucucoind
            sleep 30
            if pgrep -x 'fucucoind' > /dev/null; then
                echo -e "${RED}Can't stop fucucoind! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your fucucoin Masternode Will be Updated To The Latest Version v1.0.1 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'fucucoinauto.sh' | crontab -

#Stop fucucoind by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/fucucoin*
mkdir FUCUCOIN_1.0.1
cd FUCUCOIN_1.0.1
wget https://github.com/BigRock88/fucucoin/releases/download/1.0.1/fucucoin-1.0.1-linux.tar.gz
tar -xzvf fucucoin-1.0.1-linux.tar.gz
mv fucucoind /usr/local/bin/fucucoind
mv fucucoin-cli /usr/local/bin/fucucoin-cli
chmod +x /usr/local/bin/fucucoin*
rm -rf ~/.fucucoin/blocks
rm -rf ~/.fucucoin/chainstate
rm -rf ~/.fucucoin/sporks
rm -rf ~/.fucucoin/peers.dat
cd ~/.fucucoin/
wget https://github.com/BigRock88/fucucoin/releases/download/1.0.1/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.fucucoin/bootstrap.zip ~/FUCUCOIN_1.0.1


# add new nodes to config file
sed -i '/addnode/d' ~/.fucucoin/fucucoin.conf

echo "addnode=192.3.253.73
addnode=107.174.228.101" >> ~/.fucucoin/fucucoin.conf

#start fucucoind
fucucoind -daemon

printf '#!/bin/bash\nif [ ! -f "~/.fucucoin/fucucoin.pid" ]; then /usr/local/bin/fucucoind -daemon ; fi' > /root/fucucoinauto.sh
chmod -R 755 /root/fucucoinauto.sh
#Setting auto start cron job for fucucoin  
if ! crontab -l | grep "fucucoinauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/fucucoinauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"

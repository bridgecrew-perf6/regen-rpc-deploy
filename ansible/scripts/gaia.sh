#!/bin/bash
set -ux

cd $HOME

# Install Go
curl -OL https://go.dev/dl/go1.18.3.linux-amd64.tar.gz 
sudo tar -C /usr/local -xvf go1.18.3.linux-amd64.tar.gz 
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bashrc 
rm go1.18.3.linux-amd64.tar.gz 
source ~/.bashrc

export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

#Install gaia
git clone https://github.com/regen-network/regen-ledger.git
git config --global user.email "regen@regen.regen"
git config --global user.name "regen-1"
git checkout v3.0.0

cd $HOME/regen-ledger
make install

export HOME_DIR=~/.regen

regen unsafe-reset-all

# MAKE HOME FOLDER AND GET GENESIS
regen init public_rpc --home $HOME_DIR
wget https://raw.githubusercontent.com/regen-network/mainnet/main/regen-1/genesis.json -O $HOME_DIR/config/genesis.json 

INTERVAL=10

# GET TRUST HASH AND TRUST HEIGHT

LATEST_HEIGHT=$(curl -s http://public-rpc.regen.vitwit.com:26657/block | jq -r .result.block.header.height);
BLOCK_HEIGHT=$(($LATEST_HEIGHT-$INTERVAL))
TRUST_HASH=$(curl -s "http://public-rpc.regen.vitwit.com:26657/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)


# TELL USER WHAT WE ARE DOING
echo "TRUST HEIGHT: $BLOCK_HEIGHT"
echo "TRUST HASH: $TRUST_HASH"


# expor state sync vars
export REGEN_STATESYNC_ENABLE=true
export REGEN_P2P_MAX_NUM_OUTBOUND_PEERS=200
export REGEN_P2P_MAX_NUM_INBOUND_PEERS=200
export REGEN_STATESYNC_RPC_SERVERS="http://public-rpc.regen.vitwit.com:26657,https://rpc.regen.forbole.com:443,https://regen.stakesystems.io:2053"
export REGEN_STATESYNC_TRUST_HEIGHT=$BLOCK_HEIGHT
export REGEN_STATESYNC_TRUST_HASH=$TRUST_HASH
export REGEN_P2P_SEEDS="aebb8431609cb126a977592446f5de252d8b7fa1@104.236.201.138:26656, d309774e794b111a0fa2056f40aed9d488b6195e@regen-seed.sunshinevalidation.io:32064"
export REGEN_P2P_PERSISTENT_PEERS=$(curl -s https://raw.githubusercontent.com/regen-network/mainnet/main/regen-1/peer-nodes.txt | paste -sd,)

sed -i '/persistent_peers =/c\persistent_peers = "'"$REGEN_P2P_PERSISTENT_PEERS"'"' $HOME_DIR/config/config.toml
sed -i '/seeds =/c\seeds = "'"$REGEN_P2P_SEEDS"'"' $HOME_DIR/config/config.toml
sed -i '/max_num_outbound_peers =/c\max_num_outbound_peers = '$REGEN_P2P_MAX_NUM_OUTBOUND_PEERS'' $HOME_DIR/config/config.toml
sed -i '/max_num_inbound_peers =/c\max_num_inbound_peers = '$REGEN_P2P_MAX_NUM_INBOUND_PEERS'' $HOME_DIR/config/config.toml
sed -i '/enable =/c\enable = true' $HOME_DIR/config/config.toml
sed -i '/rpc_servers =/c\rpc_servers = "'"$REGEN_STATESYNC_RPC_SERVERS"'"' $HOME_DIR/config/config.toml
sed -i '/trust_height =/c\trust_height = '$REGEN_STATESYNC_TRUST_HEIGHT'' $HOME_DIR/config/config.toml
sed -i '/trust_hash =/c\trust_hash = "'"$REGEN_STATESYNC_TRUST_HASH"'"' $HOME_DIR/config/config.toml
sed -i '/127.0.0.1:26657/c laddr = "tcp://0.0.0.0:26657"' $HOME_DIR/config/config.toml 
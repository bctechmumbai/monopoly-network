#!/bin/bash

source "./utils/base-functions.sh"

export $(grep -v '^#' ../.env | xargs)

export PATH=${PROJECT_NETWORK_PATH}/bin:${PATH}
echo ""
echo "Creating genesis block..."
echo ""
inputLog "FABRIC_CONFIG_PATH: ${FABRIC_CONFIG_PATH}"
inputLog "GENESIS_BLOCK_PATH: ${GENESIS_BLOCK_PATH}"
echo ""
if [ -f "${GENESIS_BLOCK_PATH}/genesis.block" ]; then
    echo "Cant't generate genesis block, file already exists: ${GENESIS_BLOCK_PATH}/genesis.block"
    echo "Try using 'reboot' or 'down' to remove whole network or 'start' to reuse it"
    exit 1 
fi
echo "configtxgen --configPath ${FABRIC_CONFIG_PATH} -profile OrdererGenesis -outputBlock ${GENESIS_BLOCK_PATH}/genesis.block -channelID system-channel"

configtxgen --configPath ${FABRIC_CONFIG_PATH} -profile OrdererGenesis -outputBlock ${GENESIS_BLOCK_PATH}/genesis.block -channelID system-channel


# ssh bepds@10.152.62.7 mkdir -p ${GENESIS_BLOCK_PATH}

# scp -r ${GENESIS_BLOCK_PATH}/genesis.block  bepds@10.152.62.7:${GENESIS_BLOCK_PATH}

# ssh bepds@10.152.62.8 mkdir -p ${GENESIS_BLOCK_PATH}

# scp -r ${GENESIS_BLOCK_PATH}/genesis.block  bepds@10.152.62.8:${GENESIS_BLOCK_PATH}

# ssh bepds@10.152.62.9  mkdir -p ${GENESIS_BLOCK_PATH}

# scp -r ${GENESIS_BLOCK_PATH}/genesis.block  bepds@10.152.62.9:${GENESIS_BLOCK_PATH}

# ssh bepds@10.152.62.10  mkdir -p ${GENESIS_BLOCK_PATH}

# scp -r ${GENESIS_BLOCK_PATH}/genesis.block  bepds@10.152.62.10:${GENESIS_BLOCK_PATH}


# rsync -a /blockchain_network/Network/system-genesis-block bepds@10.152.62.7:/blockchain_network/Network/
# rsync -a /blockchain_network/Network/system-genesis-block bepds@10.152.62.8:/blockchain_network/Network/
# rsync -a /blockchain_network/Network/system-genesis-block bepds@10.152.62.9:/blockchain_network/Network/
# rsync -a /blockchain_network/Network/system-genesis-block bepds@10.152.62.10:/blockchain_network/Network/

#!/bin/bash

if ! curl --fail --connect-timeout 10 --verbose https://gui.xmr.pm/files/block.txt --output /var/monero/block.txt; then
  touch /var/monero/block.txt
fi

exec "/monerod" \
--data-dir /var/monero \
--ban-list /var/monero/block.txt \
--zmq-pub=tcp://0.0.0.0:18083 --rpc-bind-ip=0.0.0.0 --rpc-bind-port 18081 \
--non-interactive --confirm-external-bind --restricted-rpc --allow-local-ip --no-igd \
--fast-block-sync 1 --prep-blocks-threads $(nproc) --sync-pruned-blocks --prune-blockchain --check-updates disabled \
--disable-dns-checkpoints \
--in-peers 32 \
--out-peers 32 \
--add-priority-node node.supportxmr.com:18080 \
--add-priority-node opennode.xmr-tw.org:18080 \
--add-priority-node node.moneroworld.com:18080 \
--add-priority-node uwillrunanodesoon.moneroworld.com:18080 \
--add-priority-node nodes.hashvault.pro:18080 \
--add-priority-node monero.sphinxlogic.com:18080 \
--add-priority-node monero.nolog.network:18080 \
--add-priority-node node.monerooutreach.org:18080 \
--add-priority-node nodex.monerujo.io:18080 \
"$@"
#!/bin/bash

echo "Waiting until monerod has synchronized or booted up..."
while [[ "$(curl --silent http://monero:18081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -H 'Content-Type: application/json' | jq '.result.synchronized')" != "true" ]]; do
  sleep 1
done

P2POOL_CONFIG=""

if [[ -f "/p2pool/data/config.json" ]]; then
  P2POOL_CONFIG="--config /p2pool/data/config.json"
fi

echo "Starting p2pool with config "

exec "/p2pool/p2pool" \
${P2POOL_CONFIG} \
--host monero \
--rpc-port 18081 --zmq-port 18083 \
"$@"
#!/bin/bash

echo "Waiting until monerod has synchronized or booted up..."
while [[ "$(curl --silent http://monero:18081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -H 'Content-Type: application/json' | jq '.result.synchronized')" != "true" ]]; do
  sleep 1
done

echo "Starting p2pool"

exec "/p2pool/p2pool" \
--config "/p2pool/config.json" \
--host monero \
--rpc-port 18081 --zmq-port 18083 \
"$@"
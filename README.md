# Monero Wallet RPC

RPC client implementation for monero wallets in nim.

### Start RPC daemon in stagenet (without digest auth)

```bash
./monero-wallet-rpc --wallet-file /tmp/wallet --daemon-address http://node.supportxmr.com:18081 --stagenet --rpc-bind-port 18082 --password 'password' --disable-rpc-login
```

### Install monero_wallet_rpc

```bash
nimble install
```

### Example Code

```nim
# TODO
```
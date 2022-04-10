# Nim Monero Wallet RPC Client

<p align="center">
<img src="./doc/monero-xmr-logo.png" alt="Monero Logo" width="200" />
</p>

Experimental client implementation for the Monero wallet RPC server in nim.

DISCLAIMER: This is not tested intensively yet. Test your code in the stagenet before using these bindings.

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
import monero_wallet_rpc, options

# defaults to host 127.0.0.1 and port 18082
let client = newWalletRpcClient()

let balanceRequest = client.getBalance(GetBalanceRequest())

# fields have the same names as defined in https://www.getmonero.org/resources/developer-guides/wallet-rpc.html 
echo "[*] Current balance: " & $balanceRequest.data.balance

# show raw RPC result
echo balanceRequest.rawBody

echo "[*] Creating new address"
let createAddressRequest = client.createAddress(
    CreateAddressRequest(
        accountIndex: 0,
        label: some("my new address") # optional values need to be wrapped with some()
    )
)

if createAddressRequest.ok:
    echo "[*] Created new address at " & createAddressRequest.data.address
else:
    echo "[!] RPC request failed with status code " & createAddressRequest.statusCode
```
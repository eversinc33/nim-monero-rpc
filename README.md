# Nim Monero Wallet RPC Client

<p align="center">
<img src="./doc/monero-xmr-logo.png" alt="Monero Logo" width="200" />
</p>

Experimental client implementation for the [Monero](https://www.getmonero.org/) wallet RPC server in Nim, with support for digest authentication.

DISCLAIMER: Not all methods are tested intensively yet. Test your code in the stagenet before using these bindings.

### Start wallet RPC server in stagenet

For testing, create a wallet and start a wallet RPC server in the stagenet. For ease of use, you can `--disable-rpc-login`.

```bash
monero-wallet-cli --stagenet --generate-new-wallet  /tmp/testwallet --password secret --mnemonic-language English --offline
monero-wallet-rpc --rpc-bind-port 18082 --wallet-file /tmp/testwallet --daemon-address http://node.sethforprivacy.com:38089 --untrusted-daemon --password secret --stagenet --disable-rpc-login
```

### Install monero_wallet_rpc

```bash
git clone https://github.com/eversinc33/monero-nim && cd monero-nim
nimble install
```

### Example Code

```nim
import monerorpc, options

# connection defaults to host 127.0.0.1 and port 18082, if using digest auth, supply `username="monero", password="password"`
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
        label: some("my new address") # optional parameters need to be wrapped with some()
    )
)

if createAddressRequest.ok:
    echo "[*] Created new address at " & createAddressRequest.data.address
else:
    echo "[!] Failed with error code " & $createAddressRequest.error.code
    echo "[*] " & createAddressRequest.error.message
```

### Generate Docs

```bash
nim doc --project --outdir:htmldocs --git.url:https://github.com/eversinc33/monero-nim --git.commit:main ./src/monero_wallet_rpc.nim
```

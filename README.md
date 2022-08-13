# Nim Monero Wallet RPC Client

<p align="center">
<img src="./doc/monero-xmr-logo.png" alt="Monero Logo" width="200" />
</p>

Client implementation for both the [Monero](https://www.getmonero.org/) wallet & daemon (node) RPC server in Nim.

DISCLAIMER: Test your code in the stagenet before using these bindings in the mainnet.

## Installation

```bash
nimble install monerorpc
```

## Wallet RPC

#### Start wallet RPC server in stagenet

For testing, create a wallet and start a [Monero wallet RPC server](https://github.com/monero-project/monero) in the stagenet. For ease of use, you can `--disable-rpc-login`.

```bash
monero-wallet-cli --stagenet --generate-new-wallet  /tmp/testwallet --password secret --mnemonic-language English --offline
monero-wallet-rpc --rpc-bind-port 18082 --wallet-file /tmp/testwallet --daemon-address http://node.sethforprivacy.com:38089 --untrusted-daemon --password secret --stagenet --disable-rpc-login
```

#### Example Code

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

## Daemon RPC

The daemon RPC client works just like the wallet RPC client. So far, the *.bin-requests have not been implemented.

#### Start daemon RPC server in stagenet

Start a node daemon in the stagenet. Initial syncing will take some time.

```bash
monerod --stagenet --rpc-bind-ip 127.0.0.1 --prune-blockchain
```

#### Example Code

```nim
import monerorpc

# connection defaults to host 127.0.0.1 and port 18081, if using digest auth, supply `username="monero", password="password"`
let client = newDaemonRpcClient()

let versionRequest = client.getVersion()

if versionRequest.ok:
    # fields have the same names as defined in https://www.getmonero.org/resources/developer-guides/daemon-rpc.html 
    echo "[*] Daemon RPC version: " & $versionRequest.data.version
else:
    echo "[!] Failed with error code " & $versionRequest.error.code
    echo "[*] " & versionRequest.error.message

# show raw RPC result
echo versionRequest.rawBody
```

## Generate Docs

```bash
nim doc --project --outdir:htmldocs --git.url:https://github.com/eversinc33/monero-nim --git.commit:main ./src/monero_wallet_rpc.nim
```
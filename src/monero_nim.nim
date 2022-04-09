import json
import httpclient
import utils

type
  WalletRpcClient = object
    host: string
    port: int16
    httpClient: HttpClient

type InvalidPortException* = object of ValueError

# Create a new client for the monero
proc newWalletRpcClient*(host: string = "127.0.0.1", port: int16 = 18082): WalletRpcClient =
  if port < 1 or port > 65535:
    raise InvalidPortException.new_exception("Port must be between 1 and 65535")
  result = WalletRpcClient(
    host: host, 
    port: port, 
    httpClient: newHttpClient()
  )

# Call RPC method
proc doRpc(walletRpcClient: WalletRpcClient, call: string, arguments: JsonNode): Response =
  walletRpcClient.httpClient.headers = newHttpHeaders({ "Content-Type": "application/json" })
  let body = %*{
    "json_rpc": "2.0",
    "method": call,
    "params": arguments
  }
  let host = "http://" & walletRpcClient.host & ":" & $walletRpcClient.port & "/json_rpc"
  result = walletRpcClient.httpClient.request(host, httpMethod = HttpPost, body = $body)

# ===== Monero Wallet RPC calls ======
# see https://www.getmonero.org/resources/developer-guides/wallet-rpc.html#get_address

# Connect the RPC server to a Monero daemon.
proc setDaemon*(
  walletRpcClient: WalletRpcClient, 
  address: string = "", 
  trusted: bool = false, 
  ssl_support: Daemon_SSL_Support = Daemon_SSL_Support.Autodetect,
  ssl_certificate_path: string = "",
  ssl_ca_file: string = "",
  ssl_allowed_fingerprints: string = "",
  ssl_allow_any_cert: bool = false
  ): Response =
  return walletRpcClient.doRpc(
    "set_daemon", 
    %*{
      "address": address,
      "trusted": trusted,
      "ssl_support": ssl_support,
      "ssl_certificate_path": ssl_certificate_path,
      "ssl_ca_file": ssl_ca_file,
      "ssl_allowed_fingerprints": ssl_allowed_fingerprints,
      "ssl_allow_any_cert": ssl_allow_any_cert      
    })

# Return the wallet's balance.
proc getBalance*(walletRpcClient: WalletRpcClient, account_index: uint = 0, address_indices: seq[uint] = @[]): Response =
  return walletRpcClient.doRpc("get_balance", %*{"account_index": account_index, "address_indices": address_indices })

# Return the wallet's addresses for an account. 
proc getAddress*(walletRpcClient: WalletRpcClient, account_index: uint = 0, address_index: seq[uint] = @[]): Response =
  return walletRpcClient.doRpc("get_address", %*{"account_index": account_index, "address_index": address_index })

# Get account and address indexes from a specific (sub)address
proc getAddressIndex*(walletRpcClient: WalletRpcClient, address: string): Response =
  return walletRpcClient.doRpc("get_address_index", %*{"address": address })

# Create a new address for an account. Optionally, label the new address.
proc createAddress*(walletRpcClient: WalletRpcClient, account_index: uint = 0, label: string = ""): Response =
  return walletRpcClient.doRpc("create_address", %*{"account_index": account_index, "label": label })

# Label an address.
proc labelAddress*(walletRpcClient: WalletRpcClient, major_index, minor_index: uint, label: string): Response =
  return walletRpcClient.doRpc("label_address", %*{"index": {"major": major_index, "minor": minor_index }, "label": label })

# Analyzes a string to determine whether it is a valid monero wallet address and returns the result and the address specifications.
proc validateAddress*(walletRpcClient: WalletRpcClient, address: string, any_net_type: bool = false, allow_openalias: bool = false): Response =
  return walletRpcClient.doRpc("validate_address", %*{"address": address, "any_net_type": any_net_type, "allow_openalias": allow_openalias})

# Get all accounts for a wallet. Optionally filter accounts by tag.
proc getAccounts*(walletRpcClient: WalletRpcClient, tag: string = ""): Response =
  return walletRpcClient.doRpc("get_accounts", %*{"tag":tag})

# Create a new account with an optional label.
proc createAccount*(walletRpcClient: WalletRpcClient, label: string = ""): Response =
  return walletRpcClient.doRpc("create_account", %*{"label": label})

# Label an account.
proc labelAccount*(walletRpcClient: WalletRpcClient, account_index: uint, label: string): Response =
  return walletRpcClient.doRpc("label_account", %*{"account_index": account_index, "label": label})

# Get a list of user-defined account tags.
proc getAccountTags*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("get_account_tags", %*{})

# TODO: tag_accounts
import json
import httpclient
import utils
import options

type
  WalletRpcClient = object
    host: string
    port: int16
    httpClient: HttpClient

type InvalidPortException* = object of ValueError

# Create a new client for the monero
# TODO: add authentication (digest authentication)
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


type 
  GetBalanceRequest* = object
    account_index*: uint
    address_indices*: Option[seq[uint]]

  GetAddressRequest* = object 
    account_index*: uint
    address_index*: Option[seq[uint]]

  GetAddressIndexRequest* = object
    address*: string

  CreateAddressRequest* = object
    account_index*: uint
    label*: Option[string]

  Index* = object
    major*: uint
    minor*: uint

  LabelAddressRequest* = object
    index*: Index
    label*: string

  ValidateAddressRequest* = object
    address*: string
    any_net_type*: Option[bool]
    allow_openalias*: Option[bool]

  GetAccountsRequest* = object
    tag*: Option[string]

  CreateAccountRequest* = object
    label*: Option[string]

  LabelAccountRequest* = object
    account_index*: uint
    label*: string

  TagAccountsRequest* = object
    tag*: string
    accounts*: seq[uint]

  UntagAccountsRequest* = object
    accounts*: seq[uint]
  
  SetAccountTagDescriptionRequest* = object
    tag*: string
    description*: string

  Destination* = object
    amount*: uint
    address*: string

  TransferRequest* = object 
    destinations*: seq[Destination]
    account_index*: Option[uint]
    subaddr_indices*: Option[seq[uint]]
    priority*: TransferPriority
    `mixin`*: uint
    ring_size: uint
    unlock_time: uint
    get_tx_key: Option[bool]
    do_not_relay: Option[bool]
    get_tx_hex: Option[bool]
    get_tx_metadata: Option[bool]

  TransferSplitRequest* = object 
    destinations*: seq[Destination]
    account_index*: Option[uint]
    subaddr_indices*: Option[seq[uint]]
    `mixin`*: uint
    ring_size: uint
    unlock_time: uint
    get_tx_key: Option[bool]
    priority*: TransferPriority
    do_not_relay: Option[bool]
    get_tx_hex: Option[bool]
    new_algorithm*: Option[bool]
    get_tx_metadata: Option[bool]

  SignTransferRequest* = object
    unsigned_txset*: string
    export_raw*: Option[bool]

  SubmitTransferRequest* = object
    tx_data_hex*: string

  SweepDustRequest* = object 
    get_tx_keys*: Option[bool]
    do_not_relay*: Option[bool]
    get_tx_hex*: Option[bool]
    get_tx_metadata*: Option[bool]

  SweepAllRequest* = object
    address*: string
    account_index*: uint
    subaddr_indices*: Option[seq[uint]]
    priority*: Option[TransferPriority]
    `mixin`*: uint
    ring_size*: uint
    unlock_time*: uint
    get_tx_keys*: Option[bool]
    below_amount*: Option[uint]
    do_not_relay*: Option[bool]
    get_tx_hex*: Option[bool]
    get_tx_metadata*: Option[bool]

  SweepSingleRequest* = object
    address*: string
    account_index*: uint
    subaddr_indices*: Option[seq[uint]]
    priority*: Option[TransferPriority]
    `mixin`*: uint
    ring_size*: uint
    unlock_time*: uint
    get_tx_keys*: Option[bool]
    key_image*: string
    below_amount*: Option[uint]
    do_not_relay*: Option[bool]
    get_tx_hex*: Option[bool]
    get_tx_metadata*: Option[bool]

  RelayTxRequest* = object
    hex*: string

  GetPaymentsRequest* = object
    payment_id*: string

  GetBulkPaymentsRequest* = object
    payment_ids*: seq[string]
    min_block_height*: uint

  IncomingTransfersRequest* = object
    transfer_type*: TransferType
    account_index*: Option[uint]
    subaddr_indices*: Option[seq[uint]]

  QueryKeyRequest* = object
    key_type*: KeyType

  MakeIntegratedAddressRequest* = object
    standard_address*: Option[string]
    payment_id*: Option[string]

  SplitIntegratedAddressRequest* = object
    integrated_address*: string
  


# Return the wallet's balance.
proc getBalance*(walletRpcClient: WalletRpcClient, params: GetBalanceRequest): Response =
  return walletRpcClient.doRpc("get_balance", %*params)

# Return the wallet's addresses for an account. 
proc getAddress*(walletRpcClient: WalletRpcClient, params: GetAddressRequest): Response =
  return walletRpcClient.doRpc("get_address", %*params)

# Get account and address indexes from a specific (sub)address
proc getAddressIndex*(walletRpcClient: WalletRpcClient, params: GetAddressIndexRequest): Response =
  return walletRpcClient.doRpc("get_address_index", %*params)

# Create a new address for an account. Optionally, label the new address.
proc createAddress*(walletRpcClient: WalletRpcClient, params: CreateAddressRequest): Response =
  return walletRpcClient.doRpc("create_address", %*params)

# Label an address.
proc labelAddress*(walletRpcClient: WalletRpcClient, params: LabelAddressRequest): Response =
  return walletRpcClient.doRpc("label_address", %*params)

# Analyzes a string to determine whether it is a valid monero wallet address and returns the result and the address specifications.
proc validateAddress*(walletRpcClient: WalletRpcClient, params: ValidateAddressRequest): Response =
  return walletRpcClient.doRpc("validate_address", %*params)

# Get all accounts for a wallet. Optionally filter accounts by tag.
proc getAccounts*(walletRpcClient: WalletRpcClient, params: GetAccountsRequest): Response =
  return walletRpcClient.doRpc("get_accounts", %params)

# Create a new account with an optional label.
proc createAccount*(walletRpcClient: WalletRpcClient, params: CreateAccountRequest): Response =
  return walletRpcClient.doRpc("create_account", %*params)

# Label an account.
proc labelAccount*(walletRpcClient: WalletRpcClient, params: LabelAccountRequest): Response =
  return walletRpcClient.doRpc("label_account", %*params)

# Get a list of user-defined account tags.
proc getAccountTags*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("get_account_tags", %*{})

# Apply a filtering tag to a list of accounts.
proc tagAccounts*(walletRpcClient: WalletRpcClient, params: TagAccountsRequest): Response =
  return walletRpcClient.doRpc("tag_accounts", %*params)

# Remove filtering tag from a list of accounts.
proc untagAccounts*(walletRpcClient: WalletRpcClient, params: UntagAccountsRequest): Response =
  return walletRpcClient.doRpc("untag_accounts", %*params)

# Set description for an account tag.
proc setAccountTagDescription*(walletRpcClient: WalletRpcClient, params: SetAccountTagDescriptionRequest): Response =
  return walletRpcClient.doRpc("set_account_tag_description", %*params)

# Returns the wallet's current block height.
proc getHeight*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("set_account_tag_description", %*{})

# Send monero to a number of recipients.
proc transfer*(walletRpcClient: WalletRpcClient, params: TransferRequest): Response =
  return walletRpcClient.doRpc("transfer", %*params)

# Same as transfer, but can split into more than one tx if necessary.
proc transferSplit*(walletRpcClient: WalletRpcClient, params: TransferSplitRequest): Response =
  return walletRpcClient.doRpc("transfer_split", %*params)

# Sign a transaction created on a read-only wallet (in cold-signing process)
proc signTransfer*(walletRpcClient: WalletRpcClient, params: SignTransferRequest): Response =
  return walletRpcClient.doRpc("sign_transfer", %*params)
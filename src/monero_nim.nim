import json
import httpclient
import enums
import options

type
  WalletRpcClient = object
    host: string
    port: int16
    httpClient: HttpClient

type InvalidPortException* = object of ValueError

# Create a new client for the monero wallet
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

type
  Index* = object
    major*: uint
    minor*: uint

  Destination* = object
    amount*: uint
    address*: string

  SignedKeyImage* = object
    key_image: string
    signature: string

type 
  SetDaemonRequest* = object
    address*: Option[string]
    trusted*: Option[bool]
    ssl_support*: Option[Daemon_SSL_Support]
    ssl_private_key_path*: Option[string]
    ssl_certificate_path*: Option[string]
    ssl_ca_file*: Option[string]
    ssl_allowed_fingerprints*: Option[seq[string]]
    ssl_allow_any_cert*: Option[bool]

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

  SetTxNotesRequest* = object
    txids*: seq[string]
    notes*: seq[string]

  GetTxNotesRequest* = object
    txids*: seq[string]

  SetAttributeRequest* = object
    key*: string
    value*: string
  
  GetAttributeRequest* = object
    key*: string

  GetTxKeyRequest* = object
    txid*: string

  CheckTxKeyRequest* = object
    txid*: string
    tx_key*: string
    address*: string

  GetTxProofRequest* = object
    txid*: string
    address*: string
    message*: Option[string]

  CheckTxProofRequest* = object
    txid*: string
    address*: string
    message*: Option[string]   
    signature*: string

  GetSpendProofRequest* = object
    txid*: string
    message*: Option[string]    

  CheckSpendProofRequest* = object
    txid*: string
    message*: Option[string]   
    signature*: string

  GetReserveProofRequest* = object
    all*: bool
    account_index*: uint
    amount*: uint
    message*: Option[string]

  CheckReserveProofRequest* = object
    address*: string
    message*: Option[string]   
    signature*: string

  GetTransfersRequest* = object
    `in`*: bool
    `out`*: bool
    pending: bool
    failed: bool
    pool: bool
    filter_by_height: Option[bool]
    min_height: Option[uint]
    max_height: Option[uint]
    account_index: Option[uint]
    subaddr_indices: Option[seq[uint]]

  GetTransferByTxidRequest* = object
    txid*: string
    account_index*: Option[uint]

  DescribeTransferRequest* = object
    unsigned_txset*: Option[string]
    multisig_txset*: Option[string]

  SignRequest* = object
    data*: string

  VerifyRequest* = object
    data*: string
    address*: string
    signature*: string

  ExportOutputsRequest* = object
    all*: Option[bool]
  
  ImportOutputsRequest* = object
    outputs_data_hex*: string

  ExportKeyImagesRequest* = object
    all*: Option[bool]

  ImportKeyImagesRequest* = object
    signed_key_images*: seq[SignedKeyImage]

  MakeUriRequest* = object
    address*: string
    amount*: Option[uint]
    payment_id*: Option[string]
    recipient_name*: Option[string]
    tx_description*: Option[string]

  ParseUriRequest* = object
    uri*: string

  GetAddressBookRequest* = object
    entries*: seq[uint]

  AddAddressBookRequest* = object
    address*: string
    payment_id*: Option[string]
    description*: Option[string]

  EditAddressBookRequest* = object
    index*: uint
    set_address*: bool
    address*: Option[string]
    set_description*: bool
    description*: Option[string]
    set_payment_id*: bool
    payment_id*: Option[string]

  DeleteAddressBookRequest* = object
    index*: uint

  RefreshRequest* = object
    start_height*: Option[uint]

  AutoRefreshRequest* = object
    enable*: Option[bool]
    period*: Option[uint]

  StartMiningRequest* = object
    threads_count*: uint
    do_background_mining*: bool
    ignore_battery*: bool

  CreateWalletRequest* = object
    filename*: string
    password*: Option[string]
    language*: string

  GenerateFromKeysRequest* = object
    restore_height*: Option[int]
    filename*: string
    address*: string
    spendkey*: Option[string]
    viewkey*: string
    password*: string
    autosave_current*: Option[bool]

  OpenWalletRequest* = object
    filename*: string
    password*: Option[string]

  RestoreDeterministicWalletRequest* = object
    filename*: string
    password*: string
    seed*: string
    restore_height*: Option[int]
    language*: Option[string]
    seed_offset*: Option[string]
    autosave_current*: bool

  ChangeWalletPasswordRequest* = object
    old_password*: Option[string]
    new_password*: Option[string]

  MakeMultisigRequest* = object
    multisig_info*: seq[string]
    threshold*: uint
    password*: string

  ImportMultisigInfoRequest* = object
    info*: seq[string]

  FinalizeMultisigRequest* = object
    multisig_info*: seq[string]
    password*: string

  SignMultisigRequest* = object
    tx_data_hex*: string

  SubmitMultisigRequest* = object
    tx_data_hex*: string

# Connect the RPC server to a Monero daemon.
proc setDaemon*(walletRpcClient: WalletRpcClient, params: SetDaemonRequest): Response =
  return walletRpcClient.doRpc("set_daemon", %*params)

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
import options
import enums

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

  SubAddressInformation* = object
    address_index*: uint
    address*: string
    balance*: uint
    unlocked_balance*: uint
    label*: string
    num_unspent_outputs*: uint

type EmptyResponse* = object

type RpcCallResult*[T] = object
  data*: T
  rawBody*: string
  statusCode*: string
  ok*: bool

type
  GetBalanceResponse* = object
    balance*: uint
    unlocked_balance*: uint
    multisig_import_needed*: bool
    per_subaddress*: Option[seq[SubAddressInformation]]

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
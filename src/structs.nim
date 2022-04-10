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

  SubAddressAccountInformation* = object
    account_index*: uint
    balance*: uint
    base_address*: string
    label*: Option[string]
    tag*: Option[string]
    unlocked_balance: uint

  AddressInformation* = object
    address*: string
    label*: string
    address_index*: uint
    used*: bool

  AddressBookEntry* = object
    address*: string
    description*: string
    index*: uint
    payment_id*: string

  AccountTagsInformation* = object
    tag*: string
    label*: string
    accounts*: seq[int]

  Payment* = object
    payment_id*: string
    tx_hash*: string
    amount*: uint
    block_height*: uint
    unlock_time*: uint
    subaddr_index*: Index
    address*: string

  Transfer* = object
    amount*: uint
    global_index*: uint
    key_image*: string
    spent*: bool
    subaddr_index*: uint
    tx_hash*: string
    tx_size*: uint

  TransferDestinationInfo* = object
    amount*: uint
    address*: string

  TransferInformation* = object
    address*: string
    amount*: uint
    confirmations*: uint
    destinations*: Option[seq[TransferDestinationInfo]]
    double_spend_seen*: bool
    fee*: uint
    height*: uint
    note*: string
    payment_id*: string
    subaddr_index*: Index
    suggested_confirmations_threshold*: uint
    timestamp*: uint
    txid*: string
    `type`*: string
    unlock_time*: uint

  TransferDescription* = object 
    amount_in*: uint64
    amount_out*: uint64
    recipients*: seq[TransferDestinationInfo]
    change_address*: string
    change_amount*: uint
    fee*: uint
    payment_id*: string
    ring_size*: uint
    unlock_time*: uint
    dummy_outputs*: uint
    extra*: string

  PaymentUri* = object
    address*: string
    amount*: uint
    payment_id*: string
    recipient_name*: string
    tx_description*: string

type RpcResponse* = object of RootObj

type EmptyResponse* = object of RpcResponse

type RpcCallResult*[T] = object
  data*: T
  rawBody*: string
  statusCode*: string
  ok*: bool

type
  GetBalanceResponse* = object of RpcResponse
    balance*: uint
    unlocked_balance*: uint
    multisig_import_needed*: bool
    per_subaddress*: Option[seq[SubAddressInformation]]

  GetAddressResponse* = object of RpcResponse
    address*: string
    addresses*: seq[AddressInformation]

  GetAddressIndexResponse* = object of RpcResponse
    index*: Index
  
  CreateAddressResponse* = object of RpcResponse
    address*: string
    address_index*: uint

  ValidateAddressResponse* = object of RpcResponse
    valid*: bool
    integrated*: bool
    subaddress*: bool
    nettype*: NetType
    openalias_address*: bool

  GetAccountsResponse* = object of RpcResponse
    subaddress_accounts*: seq[SubAddressAccountInformation]
    total_balance*: uint
    total_unlocked_balance*: uint

  CreateAccountResponse* = object of RpcResponse
    account_index*: uint
    address*: string

  GetAccountTagsResponse* = object of RpcResponse
    account_tags*: AccountTagsInformation

  GetHeightResponse* = object of RpcResponse
    height*: uint

  TransferResponse* = object of RpcResponse
    amount*: uint
    fee*: int
    multisig_txset*: string
    tx_blob*: string
    tx_hash*: string
    tx_key*: string
    tx_metadata*: string
    unsigned_txset*: string

  TransferSplitResponse* = object of RpcResponse
    tx_hash_list*: seq[string]
    tx_key_list*: seq[string]
    amount_list*: seq[int]
    fee_list*: seq[int]
    tx_blob_list*: seq[string]
    tx_metadata_list*: seq[string]
    multisig_txset*: string
    unsignet_txset*: string

  SignTransferResponse* = object of RpcResponse
    signed_txset*: string
    tx_hash_list*: seq[string]
    tx_raw_list*: seq[string]

  SubmitTransferResponse* = object of RpcResponse
    tx_hash_list*: seq[string]

  SweepDustResponse* = object of RpcResponse
    tx_hash_list*: Option[seq[string]]
    tx_key_list*: Option[seq[string]]
    amount_list*: Option[seq[int]]
    fee_list*: Option[seq[int]]
    tx_blob_list*: Option[seq[string]]
    tx_metadata_list*: Option[seq[string]]
    multisig_txset*: string
    unsigned_txset*: string

  SweepAllResponse* = object of RpcResponse
    tx_hash_list*: Option[seq[string]]
    tx_key_list*: Option[seq[string]]
    amount_list*: Option[seq[int]]
    fee_list*: Option[seq[int]]
    tx_blob_list*: Option[seq[string]]
    tx_metadata_list*: Option[seq[string]]
    multisig_txset*: string
    unsigned_txset*: string

  SweepSingleResponse* = object of RpcResponse
    tx_hash_list*: Option[seq[string]]
    tx_key_list*: Option[seq[string]]
    amount_list*: Option[seq[int]]
    fee_list*: Option[seq[int]]
    tx_blob_list*: Option[seq[string]]
    tx_metadata_list*: Option[seq[string]]
    multisig_txset*: string
    unsigned_txset*: string

  RelayTxResponse* = object of RpcResponse
    tx_hash*: string

  GetPaymentsResponse* = object of RpcResponse
    payments*: seq[Payment]

  GetBulkPaymentsResponse* = object of RpcResponse
    payments*: seq[Payment]

  IncomingTransfersResponse* = object of RpcResponse
    transfers*: seq[Transfer]

  QueryKeyResponse* = object of RpcResponse
    key*: string

  MakeIntegratedAddressResponse* = object of RpcResponse
    integrated_address*: string
    payment_id*: string

  SplitIntegratedAddressResponse* = object of RpcResponse
    is_subaddress*: bool
    payment*: string
    standard_address*: string

  GetTxNotesResponse* = object of RpcResponse
    notes*: seq[string]
  
  GetAttributeResponse* = object of RpcResponse
    value*: string

  GetTxKeyResponse* = object of RpcResponse
    tx_key*: string

  CheckTxKeyResponse* = object of RpcResponse
    confirmations*: uint
    in_pool*: bool
    received*: uint

  GetTxProofResponse* = object of RpcResponse
    signature*: string

  CheckTxProofResponse* = object of RpcResponse
    confirmations*: uint
    good*: bool
    in_pool*: bool
    received*: uint

  GetSpendProofResponse* = object of RpcResponse
    signature*: string

  CheckSpendProofResponse* = object of RpcResponse
    good*: bool

  GetReserveProofResponse* = object of RpcResponse
    signature*: string

  CheckReserveProofResponse* = object of RpcResponse
    good*: bool
    spent*: Option[uint]
    total*: Option[uint]

  GetTransfersResponse* = object of RpcResponse
    `in`: seq[TransferInformation]
    `out`: seq[TransferInformation]
    pending: seq[TransferInformation]
    failed: seq[TransferInformation]
    pool: seq[TransferInformation]

  GetTransferByTxidResponse* = object of RpcResponse
    transfer*: TransferInformation

  DescribeTransferResponse* = object of RpcResponse
    desc*: seq[TransferDescription]

  SignResponse* = object of RpcResponse
    signature*: string

  VerifyResponse* = object of RpcResponse
    good*: bool

  ExportOutputsResponse* = object of RpcResponse
    outputs_data_hex*: string

  ImportOutputsResponse* = object of RpcResponse
    num_imported*: uint

  ExportKeyImagesResponse* = object of RpcResponse
    signed_key_images*: seq[SignedKeyImage]

  ImportKeyImagesResponse* = object of RpcResponse
    height*: uint
    spent*: uint
    unspent*: uint

  MakeUriResponse* = object of RpcResponse
    uri*: string

  ParseUriResponse* = object of RpcResponse
    uri*: PaymentUri

  GetAddressBookResponse* = object of RpcResponse
    entries*: seq[AddressBookEntry]

  AddAddressBookResponse* = object of RpcResponse
    index*: uint

  RefreshResponse* = object of RpcResponse
    blocks_fetched*: uint
    received_money*: bool

  GetLanguagesResponse* = object of RpcResponse
    languages*: seq[string]

  GenerateFromKeysResponse* = object of RpcResponse
    address*: string
    info*: string

  RestoreDeterministicWalletResponse* = object of RpcResponse
    address*: string
    info*: string
    seed*: string
    was_deprecated*: bool

  IsMultisigResponse* = object of RpcResponse
    multisig*: bool
    ready*: bool
    threshold*: uint
    total*: uint

  PrepareMultisigResponse* = object of RpcResponse
    multisig_info*: string

  MakeMultisigResponse* = object of RpcResponse
    address*: string
    multisig_info*: string

  ExportMultisigInfoResponse* = object of RpcResponse
    info*: string

  ImportMultisigInfoResponse* = object of RpcResponse
    n_outputs*: uint

  FinalizeMultisigResponse* = object of RpcResponse
    address*: string

  SignMultisigResponse* = object of RpcResponse
    tx_data_hex*: string
    tx_hash_list*: seq[string]

  SubmitMultisigResponse* = object of RpcResponse
    tx_hash_list*: seq[string]

  GetVersionResponse* = object of RpcResponse
    version*: uint

  

  
    


  
        
  

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
    transfer_type*: TransferRequestType
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
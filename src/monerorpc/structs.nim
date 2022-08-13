import options
import enums

type
  HttpError* = object of IOError

  RpcError* = object
    code*: int
    message*: string

  RpcResponse* = object of RootObj

  EmptyResponse* = object of RpcResponse

  RpcCallResult*[T] = object
    rawBody*: string
    statusCode*: string
    data*: T
    ok*: bool
    error*: RpcError

# Wallet types
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

# Daemon types
type
  Node* = object
    host*: string
    ip*: string
    seconds*: uint

  NodeBan* = object
    host*: Option[string]
    ip*: Option[uint]
    ban*: bool
    seconds*: uint

  BlockHeader* = object
    block_size*: uint
    block_weight*: uint
    cumulative_difficulty*: uint64
    cumulative_difficulty_top64*: uint64
    depth*: uint
    difficulty*: uint
    hash*: string
    height*: uint
    long_term_weight*: uint
    major_version*: uint
    miner_tx_hash*: string
    minor_version*: uint
    nonce*: uint
    num_txes*: uint
    orphan_status*: bool
    pow_hash*: string
    prev_hash*: string
    reward*: uint
    timestamp*: uint
    wide_cumulative_difficulty*: string
    wide_difficulty*: string

  Gen* = object
    height*: uint

  TransactionInput* = object
    gen*: Gen

  Target* = object
    key*: string

  TransactionOutput* = object
    amount*: uint
    target*: Target

  MinerTransaction* = object
    version*: uint
    unlock_time*: uint
    vin*: seq[TransactionInput]
    vout*: seq[TransactionOutput]
    extra*: string
    signatures*: seq[string]
    tx_hashes*: seq[string]

  BlockDetails* = object
    major_version*: uint
    minor_version*: uint
    timestamp*: uint
    prev_id*: string
    nonce*: uint
    miner_tx*: MinerTransaction

  Connection* = object
    address*: string
    address_type*: int
    avg_download*: uint
    avg_upload*: uint
    connection_id*: string
    current_download*: uint
    current_upload*: uint
    height*: uint
    host*: string
    incoming*: bool
    ip*: string
    live_time*: uint
    local_ip*: bool
    localhost*: bool
    peer_id*: string
    port*: string
    pruning_seed*: uint
    recv_count*: uint
    recv_idle_time*: uint
    rpc_credits_by_hash*: uint
    rpc_port*: uint
    send_count*: uint
    send_idle_time*: uint
    state*: string
    support_flags*: uint

  Histogram* = object 
    amount*: uint
    total_instances*: uint
    unlocked_instances*: uint
    recent_instances*: uint

  Chain* = object
    block_hash*: string
    block_hashes*: seq[string]
    difficulty*, difficulty_top64*: uint64
    height*: uint
    length*: uint
    main_chain_parent_block*: string
    wide_difficulty*: string

  Peer* = object
    info*: Connection

  Span* = object
    connection_id*: string
    nblocks*: uint
    rate*: uint
    remote_address*: string
    size*: uint
    speed*: uint
    start_block_height*: uint
  
  Distribution* = object
    amount*: uint
    base*: uint
    distribution*: seq[uint]
    start_height*: uint

  TransactionEntry* = object
    as_hex*: string
    as_json*: string
    block_height*: uint
    block_timestamp*: uint
    double_spend_seen*: bool
    in_pool*: bool
    output_indices*: seq[uint]
    prunable_as_hex*: string
    prunable_hash*: string
    pruned_as_hex*: string
    tx_hash*: string

  PeerListItem* = object
    host*: string
    id*: string
    ip*: string
    last_seen*: uint
    port*: uint

  SpentOutputKeyImage* = object
    id_hash*: string
    txs_hashes*: seq[string]

  Transaction* = object
    blob_size*: uint
    do_not_relay*: bool
    double_spend_seen*: bool
    fee*: uint
    id_hash*: string
    kept_by_block*: bool
    last_failed_height*: uint
    last_failed_id_hash*: string
    last_relayed_time*: uint
    max_used_block_height*: uint
    max_used_block_hash*: string
    receive_time*: uint
    relayed*: bool
    tx_blob*: uint
    tx_json*: string

  TxPoolHisto* = object
    txs*: uint
    bytes*: uint

  PoolStats* = object
    bytes_max*, bytes_med*, bytes_min*, bytes_total*: uint
    fee_total*: uint
    histo*: seq[TxPoolHisto]
    histo_98pc*: uint
    num_10m*: uint
    num_double_spends*: uint
    num_failing*: uint
    num_not_relayed*: uint
    oldest*: uint
    txs_total*: uint

  OutKey* = object
    height*: uint
    key*: string
    mask*: string
    txid*: string
    unlocked*: bool

  GetOutputsOut* = object
    amount*: uint
    index*: uint

# Wallet RPC
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
    `in`*: Option[seq[TransferInformation]]
    `out`*: Option[seq[TransferInformation]]
    pending*: Option[seq[TransferInformation]]
    failed*: Option[seq[TransferInformation]]
    pool*: Option[seq[TransferInformation]]

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

  ExchangeMultisigKeysResponse* = object of RpcResponse
    address*: string
    multisig_info*: string

  GetVersionResponse* = object of RpcResponse
    version*: uint

  FrozenResponse* = object of RpcResponse
    frozen*: bool

  EstimateTxSizeAndWeightResponse* = object of RpcResponse
    size*: int
    weight*: int

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
    pending*: bool
    failed*: bool
    pool*: bool
    filter_by_height*: Option[bool]
    min_height*: Option[uint]
    max_height*: Option[uint]
    account_index*: Option[uint]
    subaddr_indices*: Option[seq[uint]]

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

  ExchangeMultisigKeysRequest* = object
    password*: string
    multisig_info*: string

  ScanTxRequest* = object
    txids*: seq[string]

  FreezeRequest* = object
    key_image*: string

  FrozenRequest* = object
    key_image*: string

  ThawRequest* = object
    key_image*: string

  EstimateTxSizeAndWeightRequest* = object
    n_inputs*: int
    n_outputs*: int
    ring_size*: int
    rct*: bool

# Daemon RPC
type
  GetBlockCountResponse* = object of RpcResponse
    count*: uint
    status*: string
    untrusted*: bool

  OnGetBlockHashResponse* = object of RpcResponse
    block_hash*: string

  GetBlockTemplateResponse* = object of RpcResponse
    blocktemplate_blob*: string
    blockhashing_blob*: string
    difficulty*: uint64
    difficulty_top64*: uint64
    expected_reward*: uint
    height*: uint
    next_seed_hash*: string
    prev_hash*: string
    reserved_offset*: uint
    seed_hash*: string
    seed_height*: string
    status*: string
    untrusted*: bool
    wide_difficulty*: string

  SubmitBlockResponse* = object of RpcResponse
    status*: string

  GetLastBlockHeaderResponse* = object of RpcResponse
    block_header*: BlockHeader
    credits*: uint
    status*: string
    top_hash*: string
    untrusted*: bool

  GetBlockHeaderByHashResponse* = object of RpcResponse
    block_header*: BlockHeader
    status*: string
    untrusted*: bool

  GetBlockHeaderByHeightResponse* = GetBlockHeaderByHashResponse

  GetBlockHeadersRangeResponse* = object of RpcResponse
    credits*: uint
    headers*: seq[BlockHeader]
    status*: string
    top_hash*: string
    untrusted*: bool

  GetBlockResponse* = object of RpcResponse
    blob*: string
    block_header*: BlockHeader
    credits*: uint
    json*: BlockDetails
    status*: string
    top_hash*: string
    untrusted*: bool

  GetConnectionsResponse* = object of RpcResponse
    connections*: seq[Connection]
    status*: string
    untrusted*: bool

  GetInfoResponse* = object of RpcResponse
    adjusted_time*: uint
    alt_blocks_count*: uint
    block_weight_limit*: uint
    block_weight_median*: uint
    bootstrap_daemon_address*: string
    busy_syncing*: bool
    credits*: uint
    cumulative_difficulty*: uint64
    cumulative_difficulty_top64*: uint64
    database_size*: uint
    difficulty*: uint64
    difficulty_top64*: uint64
    free_space*: uint
    grey_peerlist_size*: uint
    height*: uint
    height_without_bootstrap*: uint
    incoming_connections_count*: uint
    mainnet*: bool
    nettype*: NetType
    offline*: bool
    outgoing_connections_count*: uint
    rpc_connections_count*: uint
    stagenet*: bool
    start_time*: uint
    status*: string
    synchronized*: bool
    target*: uint
    target_height*: uint
    testnet*: bool
    top_block_hash*: string
    top_hash*: string
    tx_count*: uint
    tx_pool_size*: uint
    untrusted*: bool
    update_available*: bool
    version*: string
    was_bootstrap_ever_used*: bool
    white_peerlist_size*: uint
    wide_cumulative_difficulty*: string
    wide_difficulty*: string

  HardForkInfoResponse* = object of RpcResponse
    credits*: uint
    earliest_height*: uint
    enabled*: bool
    state*: uint
    status*: string
    threshold*: uint
    top_hash*: string
    untrusted*: bool
    version*: uint
    votes*: uint
    voting*: uint
    window*: uint

  SetBansResponse* = object of RpcResponse
    status*: string
    untrusted*: bool

  GetBansResponse* = object of RpcResponse
    bans*: seq[Node]
    status*: string
    untrusted*: bool

  FlushTxPoolResponse* = object of RpcResponse
    status*: string
  
  GetOutputHistogramResponse* = object of RpcResponse
    credits*: uint
    histogram*: seq[Histogram]
    status*: string
    top_hash*: string
    untrusted*: bool

  GetCoinbaseTxSumResponse* = object of RpcResponse
    credits*: uint
    emission_amount*: uint64
    emission_amount_top64*: uint64
    fee_amount*: uint64
    fee_amount_top64*: uint64
    status*: string
    top_hash*: string
    untrusted*: bool
    wide_emission_amount*: string
    wide_fee_amount*: string

  # wallet has a response with the same name ..
  GetVersionResponse_Daemon* = object of RpcResponse
    release*: bool
    status*: string
    untrusted*: bool
    version*: uint
    
  GetFeeEstimateResponse* = object of RpcResponse
    credits*: uint
    fee*: uint
    quantization_mask*: uint
    status*: string
    top_hash*: string
    untrusted*: bool

  GetAlternateChainsResponse* = object of RpcResponse
    chains*: seq[Chain]
    status*: string
    untrusted*: bool

  # wallet has a response with the same name ..
  RelayTxResponse_Daemon* = object of RpcResponse
    status*: string

  SyncInfoResponse* = object of RpcResponse
    credits*: uint
    height*: uint
    next_needed_pruning_seed*: uint
    overview*: string
    peers*: seq[Peer]
    spans*: Option[seq[Span]]
    status*: string
    target_height*: uint

  GetTxpoolBacklogResponse* = object of RpcResponse
    backlog*: string # Binary. TODO
    status*: string
    untrusted*: bool

  GetOutputDistributionResponse* = object of RpcResponse
    distributions*: seq[Distribution]
    status*: string

type 
  OnGetBlockHashRequest* = object
    block_height*: array[1, int]

  GetBlockTemplateRequest* = object
    wallet_address*: string
    reserve_size*: uint

  SubmitBlockRequest* = object
    block_blob_data*: seq[string]

  GetBlockHeaderByHashRequest* = object
    hash*: string

  GetBlockHeaderByHeightRequest* = object
    height*: uint

  GetBlockHeadersRangeRequest* = object
    start_height*: uint
    end_height*: uint

  GetBlockRequest* = object
    height*: Option[uint]
    hash*: Option[string]

  SetBansRequest* = object
    bans*: seq[NodeBan]

  FlushTxPoolRequest* = object
    txids*: Option[seq[string]]

  GetOutputHistogramRequest* = object
    amounts*: seq[uint]
    min_count*: Option[uint]
    max_count*: Option[uint]
    unlocked*: Option[bool]
    recent_cutoff*: Option[uint]

  GetCoinbaseTxSumRequest* = object
    height*: uint
    count*: uint

  GetFeeEstimateRequest* = object
    grace_blocks*: Option[uint]

  # wallet has a request with the same name ..
  RelayTxRequest_Daemon* = object
    txids*: seq[string]

  GetOutputDistributionRequest* = object
    amounts*: seq[uint]
    cumulative*: Option[bool]
    from_height*: Option[uint]
    to_height*: Option[uint]

# Daemon HTTP RPC calls
type
  GetHeightResponse_Daemon* = object of RpcResponse
    hash*: string
    height*: uint
    status*: string
    untrusted*: bool

  GetTransactionsResponse* = object of RpcResponse
    missed_tx*: Option[seq[string]]
    status*: string
    top_hash*: string
    txs*: seq[TransactionEntry]
    txs_as_hex*: string
    txs_as_json*: Option[string]

  GetAltBlockHashesResponse* = object of RpcResponse
    blks_hashes*: seq[string]
    credits*: uint
    status*: string
    top_hash*: string
    untrusted*: bool

  IsKeyImageSpentResponse* = object of RpcResponse
    credits*: uint
    spent_status*: seq[range[0..2]]
    status*: string
    top_hash*: string
    untrusted*: bool

  SendRawTransactionResponse* = object of RpcResponse
    double_spend*: bool
    fee_too_low*: bool
    invalid_input*: bool
    invalid_output*: bool
    low_mixin*: bool
    not_rct*: bool
    not_relayed*: bool
    overspend*: bool
    reason*: string
    status*: string
    too_big*: bool
    untrusted*: bool

  StartMiningResponse* = object of RpcResponse
    status*: string
    untrusted*: bool

  StopMiningResponse* = object of RpcResponse
    status*: string
    untrusted*: bool

  MiningStatusResponse* = object of RpcResponse
    active*: bool
    address*: string
    bg_idle_threshold*: int
    bg_ignore_battery*: bool
    bg_min_idle_seconds*: int
    bg_target*: int
    block_reward*: int
    block_target*: int
    difficulty*, difficulty_top64*: uint64
    is_background_mining_enabled*: bool
    pow_algorithm*: string
    speed*: uint
    status*: string
    threads_count*: uint
    untrusted*: bool
    wide_difficulty*: string

  SaveBcResponse* = object of RpcResponse
    status*: string
    untrusted*: bool

  GetPeerListResponse* = object of RpcResponse
    gray_list*: seq[PeerListItem]
    status*: string
    white_list*: seq[PeerListItem]

  SetLogHashRateResponse* = object of RpcResponse
    status*: string
    untrusted*: bool

  SetLogLevelResponse* = object of RpcResponse
    status*: string
    untrusted*: bool

  SetLogCategoriesResponse* = object of RpcResponse
    categories*: string
    status*: string
    untrusted*: bool

  GetTransactionPoolResponse* = object of RpcResponse
    credits*: uint
    spent_key_images*: seq[SignedKeyImage]
    status*: string
    transactions*: seq[Transaction]

  GetTransactionPoolStatsResponse* = object of RpcResponse
    credits*: uint
    pool_stats*: PoolStats
    status*: string
    top_hash*: string
    untrusted*: bool

  StopDaemonResponse* = object of RpcResponse
    status*: string

  GetLimitResponse* = object of RpcResponse
    limit_down*: uint
    limit_up*: uint
    status*: string
    untrusted*: bool

  SetLimitResponse* = object of RpcResponse
    limit_down*: uint
    limit_up*: uint
    status*: string
    untrusted*: bool

  OutPeersResponse* = object of RpcResponse
    out_peers*: uint
    status*: string
    untrusted*: bool

  InPeersResponse* = object of RpcResponse
    in_peers*: uint
    status*: string
    untrusted*: bool

  GetOutsResponse* = object of RpcResponse
    outs*: seq[OutKey]
    status*: string
    untrusted*: bool

  UpdateResponse* = object of RpcResponse
    auto_uri*: string
    hash*: string
    path*: string
    status*: string
    untrusted*: bool
    update*: bool
    user_uri*: string
    version*: string

type 
  GetTransactionsRequest* = object
    txs_hashes*: seq[string]
    decode_as_json*: Option[bool]
    prune*: Option[bool]

  IsKeyImageSpentRequest* = object
    key_images*: seq[string]

  SendRawTransactionRequest* = object
    tx_as_hex*: string
    do_not_relay*: bool

  StartMiningRequest_Daemon* = object
    do_background_mining*: bool
    ignore_battery*: bool
    miner_address*: string
    threads_count*: uint
  
  SetLogHashRateRequest* = object    
    visible*: bool

  SetLogLevelRequest* = object
    level*: range[0..4]

  SetLogCategoriesRequest* = object
    categories*: Option[string]

  SetLimitRequest* = object
    limit_down*: int
    limit_up*: int

  OutPeersRequest* = object
    out_peers*: uint
  
  InPeersRequest* = object
    in_peers*: uint

  GetOutsRequest* = object
    outputs*: seq[GetOutputsOut]
    get_txid*: bool

  UpdateRequest* = object
    command*: UpdateCommand
    path*: Option[string]
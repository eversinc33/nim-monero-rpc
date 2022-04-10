import json
import httpclient
import structs
import options

type
  WalletRpcClient = object
    host: string
    port: int16
    httpClient: HttpClient

type InvalidPortException* = object of ValueError

# Create a new client for the monero wallet
# TODO: add authentication option (digest authentication)
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

proc setDaemon*(walletRpcClient: WalletRpcClient, params: SetDaemonRequest): Response =
  return walletRpcClient.doRpc("set_daemon", %*params)

proc getBalance*(walletRpcClient: WalletRpcClient, params: GetBalanceRequest): Response =
  return walletRpcClient.doRpc("get_balance", %*params)

proc getAddress*(walletRpcClient: WalletRpcClient, params: GetAddressRequest): Response =
  return walletRpcClient.doRpc("get_address", %*params)

proc getAddressIndex*(walletRpcClient: WalletRpcClient, params: GetAddressIndexRequest): Response =
  return walletRpcClient.doRpc("get_address_index", %*params)

proc createAddress*(walletRpcClient: WalletRpcClient, params: CreateAddressRequest): Response =
  return walletRpcClient.doRpc("create_address", %*params)

proc labelAddress*(walletRpcClient: WalletRpcClient, params: LabelAddressRequest): Response =
  return walletRpcClient.doRpc("label_address", %*params)

proc validateAddress*(walletRpcClient: WalletRpcClient, params: ValidateAddressRequest): Response =
  return walletRpcClient.doRpc("validate_address", %*params)

proc getAccounts*(walletRpcClient: WalletRpcClient, params: GetAccountsRequest): Response =
  return walletRpcClient.doRpc("get_accounts", %*params)

proc createAccount*(walletRpcClient: WalletRpcClient, params: CreateAccountRequest): Response =
  return walletRpcClient.doRpc("create_account", %*params)

proc labelAccount*(walletRpcClient: WalletRpcClient, params: LabelAccountRequest): Response =
  return walletRpcClient.doRpc("label_account", %*params)

proc getAccountTags*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("get_account_tags", %*{})

proc tagAccounts*(walletRpcClient: WalletRpcClient, params: TagAccountsRequest): Response =
  return walletRpcClient.doRpc("tag_accounts", %*params)

proc untagAccounts*(walletRpcClient: WalletRpcClient, params: UntagAccountsRequest): Response =
  return walletRpcClient.doRpc("untag_accounts", %*params)

proc setAccountTagDescription*(walletRpcClient: WalletRpcClient, params: SetAccountTagDescriptionRequest): Response =
  return walletRpcClient.doRpc("set_account_tag_description", %*params)

proc getHeight*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("get_height", %*{})

proc transfer*(walletRpcClient: WalletRpcClient, params: TransferRequest): Response =
  return walletRpcClient.doRpc("transfer", %*params)

proc transferSplit*(walletRpcClient: WalletRpcClient, params: TransferSplitRequest): Response =
  return walletRpcClient.doRpc("transfer_split", %*params)

proc signTransfer*(walletRpcClient: WalletRpcClient, params: SignTransferRequest): Response =
  return walletRpcClient.doRpc("sign_transfer", %*params)

proc submitTransfer*(walletRpcClient: WalletRpcClient, params: SubmitTransferRequest): Response =
  return walletRpcClient.doRpc("submit_transfer", %*params)

proc sweepDust*(walletRpcClient: WalletRpcClient, params: SweepDustRequest): Response =
  return walletRpcClient.doRpc("sweep_dust", %*params)

proc sweepAll*(walletRpcClient: WalletRpcClient, params: SweepAllRequest): Response =
  return walletRpcClient.doRpc("sweep_all", %*params)

proc sweepSingle*(walletRpcClient: WalletRpcClient, params: SweepSingleRequest): Response =
  return walletRpcClient.doRpc("sweep_single", %*params)

proc relayTx*(walletRpcClient: WalletRpcClient, params: RelayTxRequest): Response =
  return walletRpcClient.doRpc("relay_tx", %*params)

proc store*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("store", %*{})

proc getPayments*(walletRpcClient: WalletRpcClient, params: GetPaymentsRequest): Response =
  return walletRpcClient.doRpc("get_payments", %*params)

proc getBulkPayments*(walletRpcClient: WalletRpcClient, params: GetBulkPaymentsRequest): Response =
  return walletRpcClient.doRpc("get_bulk_payments", %*params)

proc incomingTransfers*(walletRpcClient: WalletRpcClient, params: IncomingTransfersRequest): Response =
  return walletRpcClient.doRpc("incoming_transfers", %*params)

proc queryKey*(walletRpcClient: WalletRpcClient, params: QueryKeyRequest): Response =
  return walletRpcClient.doRpc("query_key", %*params)

proc makeIntegratedAddress*(walletRpcClient: WalletRpcClient, params: MakeIntegratedAddressRequest): Response =
  return walletRpcClient.doRpc("make_integrated_address", %*params)

proc splitIntegratedAddress*(walletRpcClient: WalletRpcClient, params: SplitIntegratedAddressRequest): Response =
  return walletRpcClient.doRpc("split_integrated_address", %*params)

proc stopWallet*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("stop_wallet", %*{})

proc rescanBlockchain*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("rescan_blockchain", %*{})

proc setTxNotes*(walletRpcClient: WalletRpcClient, params: SetTxNotesRequest): Response =
  return walletRpcClient.doRpc("set_tx_notes", %*params)

proc getTxNotes*(walletRpcClient: WalletRpcClient, params: GetTxNotesRequest): Response =
  return walletRpcClient.doRpc("get_tx_notes", %*params)

proc setAttribute*(walletRpcClient: WalletRpcClient, params: SetAttributeRequest): Response =
  return walletRpcClient.doRpc("set_attribute", %*params)

proc getAttribute*(walletRpcClient: WalletRpcClient, params: GetAttributeRequest): Response =
  return walletRpcClient.doRpc("get_attribute", %*params)

proc getTxKey*(walletRpcClient: WalletRpcClient, params: GetTxKeyRequest): Response =
  return walletRpcClient.doRpc("get_tx_key", %*params)

proc checkTxKey*(walletRpcClient: WalletRpcClient, params: CheckTxKeyRequest): Response =
  return walletRpcClient.doRpc("check_tx_key", %*params)

proc getTxProof*(walletRpcClient: WalletRpcClient, params: GetTxProofRequest): Response =
  return walletRpcClient.doRpc("get_tx_proof", %*params)

proc checkTxProof*(walletRpcClient: WalletRpcClient, params: CheckTxProofRequest): Response =
  return walletRpcClient.doRpc("check_tx_proof", %*params)

proc getSpendProof*(walletRpcClient: WalletRpcClient, params: GetSpendProofRequest): Response =
  return walletRpcClient.doRpc("get_spend_proof", %*params)

proc checkSpendProof*(walletRpcClient: WalletRpcClient, params: CheckSpendProofRequest): Response =
  return walletRpcClient.doRpc("check_spend_proof", %*params)

proc getReserveProof*(walletRpcClient: WalletRpcClient, params: GetReserveProofRequest): Response =
  return walletRpcClient.doRpc("get_reserve_proof", %*params)

proc checkReserveProof*(walletRpcClient: WalletRpcClient, params: CheckReserveProofRequest): Response =
  return walletRpcClient.doRpc("check_reserve_proof", %*params)

proc getTransfers*(walletRpcClient: WalletRpcClient, params: GetTransfersRequest): Response =
  return walletRpcClient.doRpc("get_transfers", %*params)

proc getTransferByTxid*(walletRpcClient: WalletRpcClient, params: GetTransferByTxidRequest): Response =
  return walletRpcClient.doRpc("get_transfer_by_txid", %*params)

proc describeTransfer*(walletRpcClient: WalletRpcClient, params: DescribeTransferRequest): Response =
  return walletRpcClient.doRpc("describe_transfer", %*params)

proc sign*(walletRpcClient: WalletRpcClient, params: SignRequest): Response =
  return walletRpcClient.doRpc("sign", %*params)

proc verify*(walletRpcClient: WalletRpcClient, params: VerifyRequest): Response =
  return walletRpcClient.doRpc("verify", %*params)

proc exportOutputs*(walletRpcClient: WalletRpcClient, params: ExportOutputsRequest): Response =
  return walletRpcClient.doRpc("export_outputs", %*params)

proc importOutputs*(walletRpcClient: WalletRpcClient, params: ImportOutputsRequest): Response =
  return walletRpcClient.doRpc("import_outputs", %*params)

proc exportKeyImages*(walletRpcClient: WalletRpcClient, params: ExportKeyImagesRequest): Response =
  return walletRpcClient.doRpc("export_key_images", %*params)

proc importKeyImages*(walletRpcClient: WalletRpcClient, params: ImportKeyImagesRequest): Response =
  return walletRpcClient.doRpc("import_key_images", %*params)

proc makeUri*(walletRpcClient: WalletRpcClient, params: MakeUriRequest): Response =
  return walletRpcClient.doRpc("make_uri", %*params)

proc parseUri*(walletRpcClient: WalletRpcClient, params: ParseUriRequest): Response =
  return walletRpcClient.doRpc("parse_uri", %*params)

proc getAddressBook*(walletRpcClient: WalletRpcClient, params: GetAddressBookRequest): Response =
  return walletRpcClient.doRpc("get_address_book", %*params)

proc addAddressBook*(walletRpcClient: WalletRpcClient, params: AddAddressBookRequest): Response =
  return walletRpcClient.doRpc("add_address_book", %*params)

proc editAddressBook*(walletRpcClient: WalletRpcClient, params: EditAddressBookRequest): Response =
  return walletRpcClient.doRpc("edit_address_book", %*params)

proc deleteAddressBook*(walletRpcClient: WalletRpcClient, params: DeleteAddressBookRequest): Response =
  return walletRpcClient.doRpc("delete_address_book", %*params)

proc refresh*(walletRpcClient: WalletRpcClient, params: RefreshRequest): Response =
  return walletRpcClient.doRpc("refresh", %*params)

proc autoRefresh*(walletRpcClient: WalletRpcClient, params: AutoRefreshRequest): Response =
  return walletRpcClient.doRpc("auto_refresh", %*params)

proc rescanSpent*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("rescan_spent", %*{})

proc startMining*(walletRpcClient: WalletRpcClient, params: StartMiningRequest): Response =
  return walletRpcClient.doRpc("start_mining", %*params)

proc stopMining*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("stop_mining", %*{})

proc getLanguages*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("get_languages", %*{})

proc createWallet*(walletRpcClient: WalletRpcClient, params: CreateWalletRequest): Response =
  return walletRpcClient.doRpc("create_wallet", %*params)

proc generateFromKeys*(walletRpcClient: WalletRpcClient, params: GenerateFromKeysRequest): Response =
  return walletRpcClient.doRpc("generate_from_keys", %*params)

proc openWallet*(walletRpcClient: WalletRpcClient, params: OpenWalletRequest): Response =
  return walletRpcClient.doRpc("open_wallet", %*params)

proc restoreDeterministicWallet*(walletRpcClient: WalletRpcClient, params: RestoreDeterministicWalletRequest): Response =
  return walletRpcClient.doRpc("restore_deterministic_wallet", %*params)

proc closeWallet*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("close_wallet", %*{})

proc changeWalletPassword*(walletRpcClient: WalletRpcClient, params: ChangeWalletPasswordRequest): Response =
  return walletRpcClient.doRpc("change_wallet_password", %*params)

proc isMultisig*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("is_multisig", %*{})

proc prepareMultisig*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("prepare_multisig", %*{})

proc makeMultisig*(walletRpcClient: WalletRpcClient, params: MakeMultisigRequest): Response =
  return walletRpcClient.doRpc("make_multisig", %*params)

proc exportMultisigInfo*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("export_multisig_info", %*{})

proc importMultisigInfo*(walletRpcClient: WalletRpcClient, params: ImportMultisigInfoRequest): Response =
  return walletRpcClient.doRpc("import_multisig_info", %*params)

proc finalizeMultisig*(walletRpcClient: WalletRpcClient, params: FinalizeMultisigRequest): Response =
  return walletRpcClient.doRpc("finalize_multisig", %*params)

proc signMultisig*(walletRpcClient: WalletRpcClient, params: SignMultisigRequest): Response =
  return walletRpcClient.doRpc("sign_multisig", %*params)

proc submitMultisig*(walletRpcClient: WalletRpcClient, params: SubmitMultisigRequest): Response =
  return walletRpcClient.doRpc("submit_multisig", %*params)

proc getVersion*(walletRpcClient: WalletRpcClient): Response =
  return walletRpcClient.doRpc("get_version", %*{})
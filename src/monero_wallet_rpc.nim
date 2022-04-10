import json
import httpclient
import structs
import options
export structs

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

template doRpc(walletRpcClient: WalletRpcClient, call: string, arguments: JsonNode, resultType: typedesc) =
  # do RPC request 
  walletRpcClient.httpClient.headers = newHttpHeaders({ "Content-Type": "application/json" })
  let body = %*{
    "json_rpc": "2.0",
    "method": call,
    "params": arguments
  }
  let host = "http://" & walletRpcClient.host & ":" & $walletRpcClient.port & "/json_rpc"
  let response = walletRpcClient.httpClient.request(host, httpMethod = HttpPost, body = $body)

  # if a result is expected, parse json into result class, else just return an empty result
  when resultType is not EmptyResponse:
    let data = parseJson(response.body)["result"].to(resultType)
  else:
    let data = EmptyResponse()

  result = RpcCallResult[resultType](
    ok: response.status == "200 Ok",
    rawBody: response.body,
    statusCode: response.status,
    data: data
  )

# ===== Monero Wallet RPC calls ======
# see https://www.getmonero.org/resources/developer-guides/wallet-rpc.html#get_address

proc setDaemon*(walletRpcClient: WalletRpcClient, params: SetDaemonRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("set_daemon", %*params, EmptyResponse)

proc getBalance*(walletRpcClient: WalletRpcClient, params: GetBalanceRequest): RpcCallResult[GetBalanceResponse] =
  walletRpcClient.doRpc("get_balance", %*params, GetBalanceResponse)

proc getAddress*(walletRpcClient: WalletRpcClient, params: GetAddressRequest): RpcCallResult[GetAddressResponse] =
  walletRpcClient.doRpc("get_address", %*params, GetAddressResponse)

proc getAddressIndex*(walletRpcClient: WalletRpcClient, params: GetAddressIndexRequest): RpcCallResult[GetAddressIndexResponse] =
  walletRpcClient.doRpc("get_address_index", %*params, GetAddressIndexResponse)

proc createAddress*(walletRpcClient: WalletRpcClient, params: CreateAddressRequest): RpcCallResult[CreateAddressResponse] =
  walletRpcClient.doRpc("create_address", %*params, CreateAddressResponse)

proc labelAddress*(walletRpcClient: WalletRpcClient, params: LabelAddressRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("label_address", %*params, EmptyResponse)

proc validateAddress*(walletRpcClient: WalletRpcClient, params: ValidateAddressRequest): RpcCallResult[ValidateAddressResponse] =
  walletRpcClient.doRpc("validate_address", %*params, ValidateAddressResponse)

proc getAccounts*(walletRpcClient: WalletRpcClient, params: GetAccountsRequest): RpcCallResult[GetAccountsResponse] =
  walletRpcClient.doRpc("get_accounts", %*params, GetAccountsResponse)

proc createAccount*(walletRpcClient: WalletRpcClient, params: CreateAccountRequest): RpcCallResult[CreateAccountResponse] =
  walletRpcClient.doRpc("create_account", %*params, CreateAccountResponse)

proc labelAccount*(walletRpcClient: WalletRpcClient, params: LabelAccountRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("label_account", %*params, EmptyResponse)

proc getAccountTags*(walletRpcClient: WalletRpcClient): RpcCallResult[GetAccountTagsResponse] =
  walletRpcClient.doRpc("get_account_tags", %*{}, GetAccountTagsResponse)

proc tagAccounts*(walletRpcClient: WalletRpcClient, params: TagAccountsRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("tag_accounts", %*params, EmptyResponse)

proc untagAccounts*(walletRpcClient: WalletRpcClient, params: UntagAccountsRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("untag_accounts", %*params, EmptyResponse)

proc setAccountTagDescription*(walletRpcClient: WalletRpcClient, params: SetAccountTagDescriptionRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("set_account_tag_description", %*params, EmptyResponse)

proc getHeight*(walletRpcClient: WalletRpcClient): RpcCallResult[GetHeightResponse] =
  walletRpcClient.doRpc("get_height", %*{}, GetHeightResponse)

proc transfer*(walletRpcClient: WalletRpcClient, params: TransferRequest): RpcCallResult[TransferResponse] =
  walletRpcClient.doRpc("transfer", %*params, TransferResponse)

proc transferSplit*(walletRpcClient: WalletRpcClient, params: TransferSplitRequest): RpcCallResult[TransferSplitResponse] =
  walletRpcClient.doRpc("transfer_split", %*params, TransferSplitResponse)

proc signTransfer*(walletRpcClient: WalletRpcClient, params: SignTransferRequest): RpcCallResult[SignTransferResponse] =
  walletRpcClient.doRpc("sign_transfer", %*params, SignTransferResponse)

proc submitTransfer*(walletRpcClient: WalletRpcClient, params: SubmitTransferRequest): RpcCallResult[SubmitTransferResponse] =
  walletRpcClient.doRpc("submit_transfer", %*params, SubmitTransferResponse)

proc sweepDust*(walletRpcClient: WalletRpcClient, params: SweepDustRequest): RpcCallResult[SweepDustResponse] =
  walletRpcClient.doRpc("sweep_dust", %*params, SweepDustResponse)

proc sweepAll*(walletRpcClient: WalletRpcClient, params: SweepAllRequest): RpcCallResult[SweepAllResponse] =
  walletRpcClient.doRpc("sweep_all", %*params, SweepAllResponse)

proc sweepSingle*(walletRpcClient: WalletRpcClient, params: SweepSingleRequest): RpcCallResult[SweepSingleResponse] =
  walletRpcClient.doRpc("sweep_single", %*params, SweepSingleResponse)

proc relayTx*(walletRpcClient: WalletRpcClient, params: RelayTxRequest): RpcCallResult[RelayTxResponse] =
  walletRpcClient.doRpc("relay_tx", %*params, RelayTxResponse)

proc store*(walletRpcClient: WalletRpcClient): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("store", %*{}, EmptyResponse)

proc getPayments*(walletRpcClient: WalletRpcClient, params: GetPaymentsRequest): RpcCallResult[GetPaymentsResponse] =
  walletRpcClient.doRpc("get_payments", %*params, GetPaymentsResponse)

proc getBulkPayments*(walletRpcClient: WalletRpcClient, params: GetBulkPaymentsRequest): RpcCallResult[GetBulkPaymentsResponse] =
  walletRpcClient.doRpc("get_bulk_payments", %*params, GetBulkPaymentsResponse)

proc incomingTransfers*(walletRpcClient: WalletRpcClient, params: IncomingTransfersRequest): RpcCallResult[IncomingTransfersResponse] =
  walletRpcClient.doRpc("incoming_transfers", %*params, IncomingTransfersResponse)

proc queryKey*(walletRpcClient: WalletRpcClient, params: QueryKeyRequest): RpcCallResult[QueryKeyResponse] =
  walletRpcClient.doRpc("query_key", %*params, QueryKeyResponse)

proc makeIntegratedAddress*(walletRpcClient: WalletRpcClient, params: MakeIntegratedAddressRequest): RpcCallResult[MakeIntegratedAddressResponse] =
  walletRpcClient.doRpc("make_integrated_address", %*params, MakeIntegratedAddressResponse)

proc splitIntegratedAddress*(walletRpcClient: WalletRpcClient, params: SplitIntegratedAddressRequest): RpcCallResult[SplitIntegratedAddressResponse] =
  walletRpcClient.doRpc("split_integrated_address", %*params, SplitIntegratedAddressResponse)

proc stopWallet*(walletRpcClient: WalletRpcClient): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("stop_wallet", %*{}, EmptyResponse)

proc rescanBlockchain*(walletRpcClient: WalletRpcClient): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("rescan_blockchain", %*{}, EmptyResponse)

proc setTxNotes*(walletRpcClient: WalletRpcClient, params: SetTxNotesRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("set_tx_notes", %*params, EmptyResponse)

proc getTxNotes*(walletRpcClient: WalletRpcClient, params: GetTxNotesRequest): RpcCallResult[GetTxNotesResponse] =
  walletRpcClient.doRpc("get_tx_notes", %*params, GetTxNotesResponse)

proc setAttribute*(walletRpcClient: WalletRpcClient, params: SetAttributeRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("set_attribute", %*params, EmptyResponse)

proc getAttribute*(walletRpcClient: WalletRpcClient, params: GetAttributeRequest): RpcCallResult[GetAttributeResponse] =
  walletRpcClient.doRpc("get_attribute", %*params, GetAttributeResponse)

proc getTxKey*(walletRpcClient: WalletRpcClient, params: GetTxKeyRequest): RpcCallResult[GetTxKeyResponse] =
  walletRpcClient.doRpc("get_tx_key", %*params, GetTxKeyResponse)

proc checkTxKey*(walletRpcClient: WalletRpcClient, params: CheckTxKeyRequest): RpcCallResult[CheckTxKeyResponse] =
  walletRpcClient.doRpc("check_tx_key", %*params, CheckTxKeyResponse)

proc getTxProof*(walletRpcClient: WalletRpcClient, params: GetTxProofRequest): RpcCallResult[GetTxProofResponse] =
  walletRpcClient.doRpc("get_tx_proof", %*params, GetTxProofResponse)

proc checkTxProof*(walletRpcClient: WalletRpcClient, params: CheckTxProofRequest): RpcCallResult[CheckTxProofResponse] =
  walletRpcClient.doRpc("check_tx_proof", %*params, CheckTxProofResponse)

proc getSpendProof*(walletRpcClient: WalletRpcClient, params: GetSpendProofRequest): RpcCallResult[GetSpendProofResponse] =
  walletRpcClient.doRpc("get_spend_proof", %*params, GetSpendProofResponse)

proc checkSpendProof*(walletRpcClient: WalletRpcClient, params: CheckSpendProofRequest): RpcCallResult[CheckSpendProofResponse] =
  walletRpcClient.doRpc("check_spend_proof", %*params, CheckSpendProofResponse)

proc getReserveProof*(walletRpcClient: WalletRpcClient, params: GetReserveProofRequest): RpcCallResult[GetReserveProofResponse] =
  walletRpcClient.doRpc("get_reserve_proof", %*params, GetReserveProofResponse)

proc checkReserveProof*(walletRpcClient: WalletRpcClient, params: CheckReserveProofRequest): RpcCallResult[CheckReserveProofResponse] =
  walletRpcClient.doRpc("check_reserve_proof", %*params, CheckReserveProofResponse)

proc getTransfers*(walletRpcClient: WalletRpcClient, params: GetTransfersRequest): RpcCallResult[GetTransfersResponse] =
  walletRpcClient.doRpc("get_transfers", %*params, GetTransfersResponse)

proc getTransferByTxid*(walletRpcClient: WalletRpcClient, params: GetTransferByTxidRequest): RpcCallResult[GetTransferByTxidResponse] =
  walletRpcClient.doRpc("get_transfer_by_txid", %*params, GetTransferByTxidResponse)

proc describeTransfer*(walletRpcClient: WalletRpcClient, params: DescribeTransferRequest): RpcCallResult[DescribeTransferResponse] =
  walletRpcClient.doRpc("describe_transfer", %*params, DescribeTransferResponse)

proc sign*(walletRpcClient: WalletRpcClient, params: SignRequest): RpcCallResult[SignResponse] =
  walletRpcClient.doRpc("sign", %*params, SignResponse)

proc verify*(walletRpcClient: WalletRpcClient, params: VerifyRequest): RpcCallResult[VerifyResponse] =
  walletRpcClient.doRpc("verify", %*params, VerifyResponse)

proc exportOutputs*(walletRpcClient: WalletRpcClient, params: ExportOutputsRequest): RpcCallResult[ExportOutputsResponse] =
  walletRpcClient.doRpc("export_outputs", %*params, ExportOutputsResponse)

proc importOutputs*(walletRpcClient: WalletRpcClient, params: ImportOutputsRequest): RpcCallResult[ImportOutputsResponse] =
  walletRpcClient.doRpc("import_outputs", %*params, ImportOutputsResponse)

proc exportKeyImages*(walletRpcClient: WalletRpcClient, params: ExportKeyImagesRequest): RpcCallResult[ExportKeyImagesResponse] =
  walletRpcClient.doRpc("export_key_images", %*params, ExportKeyImagesResponse)

proc importKeyImages*(walletRpcClient: WalletRpcClient, params: ImportKeyImagesRequest): RpcCallResult[ImportKeyImagesResponse] =
  walletRpcClient.doRpc("import_key_images", %*params, ImportKeyImagesResponse)

proc makeUri*(walletRpcClient: WalletRpcClient, params: MakeUriRequest): RpcCallResult[MakeUriResponse] =
  walletRpcClient.doRpc("make_uri", %*params, MakeUriResponse)

proc parseUri*(walletRpcClient: WalletRpcClient, params: ParseUriRequest): RpcCallResult[ParseUriResponse] =
  walletRpcClient.doRpc("parse_uri", %*params, ParseUriResponse)

proc getAddressBook*(walletRpcClient: WalletRpcClient, params: GetAddressBookRequest): RpcCallResult[GetAddressBookResponse] =
  walletRpcClient.doRpc("get_address_book", %*params, GetAddressBookResponse)

proc addAddressBook*(walletRpcClient: WalletRpcClient, params: AddAddressBookRequest): RpcCallResult[AddAddressBookResponse] =
  walletRpcClient.doRpc("add_address_book", %*params, AddAddressBookResponse)

proc editAddressBook*(walletRpcClient: WalletRpcClient, params: EditAddressBookRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("edit_address_book", %*params, EmptyResponse)

proc deleteAddressBook*(walletRpcClient: WalletRpcClient, params: DeleteAddressBookRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("delete_address_book", %*params, EmptyResponse)

proc refresh*(walletRpcClient: WalletRpcClient, params: RefreshRequest): RpcCallResult[RefreshResponse] =
  walletRpcClient.doRpc("refresh", %*params, RefreshResponse)

proc autoRefresh*(walletRpcClient: WalletRpcClient, params: AutoRefreshRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("auto_refresh", %*params, EmptyResponse)

proc rescanSpent*(walletRpcClient: WalletRpcClient): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("rescan_spent", %*{}, EmptyResponse)

proc startMining*(walletRpcClient: WalletRpcClient, params: StartMiningRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("start_mining", %*params, EmptyResponse)

proc stopMining*(walletRpcClient: WalletRpcClient): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("stop_mining", %*{}, EmptyResponse)

proc getLanguages*(walletRpcClient: WalletRpcClient): RpcCallResult[GetLanguagesResponse] =
  walletRpcClient.doRpc("get_languages", %*{}, GetLanguagesResponse)

proc createWallet*(walletRpcClient: WalletRpcClient, params: CreateWalletRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("create_wallet", %*params, EmptyResponse)

proc generateFromKeys*(walletRpcClient: WalletRpcClient, params: GenerateFromKeysRequest): RpcCallResult[GenerateFromKeysResponse] =
  walletRpcClient.doRpc("generate_from_keys", %*params, GenerateFromKeysResponse)

proc openWallet*(walletRpcClient: WalletRpcClient, params: OpenWalletRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("open_wallet", %*params, EmptyResponse)

proc restoreDeterministicWallet*(walletRpcClient: WalletRpcClient, params: RestoreDeterministicWalletRequest): RpcCallResult[RestoreDeterministicWalletResponse] =
  walletRpcClient.doRpc("restore_deterministic_wallet", %*params, RestoreDeterministicWalletResponse)

proc closeWallet*(walletRpcClient: WalletRpcClient): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("close_wallet", %*{}, EmptyResponse)

proc changeWalletPassword*(walletRpcClient: WalletRpcClient, params: ChangeWalletPasswordRequest): RpcCallResult[EmptyResponse] =
  walletRpcClient.doRpc("change_wallet_password", %*params, EmptyResponse)

proc isMultisig*(walletRpcClient: WalletRpcClient): RpcCallResult[IsMultisigResponse] =
  walletRpcClient.doRpc("is_multisig", %*{}, IsMultisigResponse)

proc prepareMultisig*(walletRpcClient: WalletRpcClient): RpcCallResult[PrepareMultisigResponse] =
  walletRpcClient.doRpc("prepare_multisig", %*{}, PrepareMultisigResponse)

proc makeMultisig*(walletRpcClient: WalletRpcClient, params: MakeMultisigRequest): RpcCallResult[MakeMultisigResponse] =
  walletRpcClient.doRpc("make_multisig", %*params, MakeMultisigResponse)

proc exportMultisigInfo*(walletRpcClient: WalletRpcClient): RpcCallResult[ExportMultisigInfoResponse] =
  walletRpcClient.doRpc("export_multisig_info", %*{}, ExportMultisigInfoResponse)

proc importMultisigInfo*(walletRpcClient: WalletRpcClient, params: ImportMultisigInfoRequest): RpcCallResult[ImportMultisigInfoResponse] =
  walletRpcClient.doRpc("import_multisig_info", %*params, ImportMultisigInfoResponse)

proc finalizeMultisig*(walletRpcClient: WalletRpcClient, params: FinalizeMultisigRequest): RpcCallResult[FinalizeMultisigResponse] =
  walletRpcClient.doRpc("finalize_multisig", %*params, FinalizeMultisigResponse)

proc signMultisig*(walletRpcClient: WalletRpcClient, params: SignMultisigRequest): RpcCallResult[SignMultisigResponse] =
  walletRpcClient.doRpc("sign_multisig", %*params, SignMultisigResponse)

proc submitMultisig*(walletRpcClient: WalletRpcClient, params: SubmitMultisigRequest): RpcCallResult[SubmitMultisigResponse] =
  walletRpcClient.doRpc("submit_multisig", %*params, SubmitMultisigResponse)

proc getVersion*(walletRpcClient: WalletRpcClient): RpcCallResult[GetVersionResponse] =
  walletRpcClient.doRpc("get_version", %*{}, GetVersionResponse)
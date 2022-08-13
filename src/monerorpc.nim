import json
import httpclient
import monerorpc/[structs, enums, utils]
import options
import strutils, strformat
import md5

export structs
export enums

let 
  DEFAULT_DAEMON_RPC_PORT = 18081
  DEFAULT_WALLET_RPC_PORT = 18082

type
  MoneroRpcClient = object of RootObj
    host*: string
    port*: range[1..65535]
    connectionString: string
    httpClient: HttpClient
    # authentication:
    digestAuthEnabled*: bool
    username*, password*: string
    nonceCount: uint

  WalletRpcClient* = object of MoneroRpcClient
  DaemonRpcClient* = object of MoneroRpcClient

proc getDigestAuthHeader(client: MoneroRpcClient, uri: string, requestMethod: HttpMethod = HttpPost): string =
  ## Calculate digest auth header for a request

  # grab header
  let r = client.httpClient.request(client.connectionString, httpMethod = requestMethod)
  let authenticateHeader = r.headers.getOrDefault("www-authenticate")
  
  # check if authentication is enabled
  if authenticateHeader.toString == "":
    raise newException(Exception, "Wallet did not send a www-authenticate header")

  # parse header
  let realm = authenticateHeader.toString.split("realm=")[1].split('"')[1]
  let nonce = authenticateHeader.toString.split("nonce=")[1].split('"')[1]
  let qop = authenticateHeader.toString.split("qop=")[1].split('"')[1]

  # generate client nonce
  let cnonce = randomString()

  when false:
    # We dont need to care about the nonce count, as we are doing session-less requests
    client.nonceCount = client.nonceCount + 1
    let nonceCount = fmt"{client.nonceCount:08}"
  else:
    # Thus we can just use a static nonce and avoid having to pass the client as var
    let nonceCount = "00000001"

  # handle unimplemented (TODO)
  if qop != "auth":
    raise newException(Exception, "Error in computing digest auth: qop '" & qop & "' not implemented")
  if not authenticateHeader.toString.contains("MD5"):
    raise newException(Exception, "Error in computing digest auth: algorithm other than MD5 has been requested")

  # calc header
  let HA1 = getMD5(client.username & ":" & realm & ":" & client.password)
  let HA2 = getMD5($requestMethod & ":" & uri)
  let response = getMD5(HA1 & ":" & nonce & ":" & nonceCount & ":" & cnonce & ":" & qop & ":" & HA2)
  result = "Digest username=\"" & client.username & "\",realm=\"" & realm & "\",nonce=\"" & nonce & "\",uri=\"" & uri & "\",qop=" & qop & ",nc=" & nonceCount & ",cnonce=\"" & cnonce & "\",response=\"" & response & "\""

proc newWalletRpcClient*(host: string = "127.0.0.1", port: range[1..65535] = DEFAULT_WALLET_RPC_PORT, username: string = "", password: string = ""): WalletRpcClient =
  ## Create a new RPC client for the Monero wallet
  let digestAuthEnabled = bool(username != "" and password != "")

  result = WalletRpcClient(
    host: host, 
    port: port, 
    connectionString: "http://" & host & ":" & $port,
    httpClient: newHttpClient(),
    digestAuthEnabled: digestAuthEnabled,
    username: username,
    password: password,
    nonceCount: 0
  )

proc newDaemonRpcClient*(host: string = "127.0.0.1", port: range[1..65535] = DEFAULT_DAEMON_RPC_PORT, username: string = "", password: string = ""): DaemonRpcClient =
  ## Create a new RPC client for the Monero daemon
  let digestAuthEnabled = bool(username != "" and password != "")

  result = DaemonRpcClient(
    host: host, 
    port: port, 
    connectionString: "http://" & host & ":" & $port,
    httpClient: newHttpClient(),
    digestAuthEnabled: digestAuthEnabled,
    username: username,
    password: password,
    nonceCount: 0
  )

template doJsonRpc(client: MoneroRpcClient, call: string, arguments: JsonNode, resultType: typedesc) =
  if client.digestAuthEnabled:
    client.httpClient.headers = newHttpHeaders({ 
      "Content-Type": "application/json",
      "Authorization": client.getDigestAuthHeader("/json_rpc") 
    })
  else:
    client.httpClient.headers = newHttpHeaders({ 
      "Content-Type": "application/json",
    })
  let body = %*{
    "json_rpc": "2.0",
    "method": call,
    "params": arguments
  }

  let response = client.httpClient.request(client.connectionString & "/json_rpc", httpMethod = HttpPost, body = $body)
  if response.status != "200 Ok":
    raise newException(HttpError, "RPC call returned non-200 HTTP code " & response.status)

  # check if call was ok, but an RPC error was thrown from the server
  let parsedJson = parseJson(response.body)
  if parsedJson.hasKey("error"):
    result = RpcCallResult[resultType](
      rawBody: response.body,
      statusCode: response.status,
      data: resultType(),
      ok: false,
      error: parseJson(response.body)["error"].to(RpcError),
    )
  else:
    # if a result is expected, parse json into result class, else just return an empty result
    when resultType is not EmptyResponse:
      let data = parsedJson["result"].to(resultType)
    else:
      let data = EmptyResponse()

    result = RpcCallResult[resultType](
      rawBody: response.body,
      statusCode: response.status,
      data: data,
      ok: true,
      error: RpcError(code: 0, message: ""),
    )

template doHttpGetRpc(client: DaemonRpcClient, path: string, resultType: typedesc) =
  if client.digestAuthEnabled:
    client.httpClient.headers = newHttpHeaders({ 
      "Authorization": client.getDigestAuthHeader(path) 
    })
  else:
    client.httpClient.headers = newHttpHeaders({ 
      "Content-Type": "application/json",
    })

  when not path.startsWith("/"):
    {.error: "Path " & path & " has to start with a slash ('/')"}
  
  let response = client.httpClient.request(client.connectionString & path, httpMethod = HttpGet)
  if response.status != "200 Ok":
    raise newException(HttpError, "HTTP GET RPC call returned non-200 HTTP code " & response.status)

  # if a result is expected, parse json into result class, else just return an empty result
  when resultType is not EmptyResponse:
    let data = parseJson(response.body).to(resultType)
  else:
    let data = EmptyResponse()

  result = RpcCallResult[resultType](
    rawBody: response.body,
    statusCode: response.status,
    data: data,
    ok: true,
    error: RpcError(code: 0, message: ""),
  )

template doHttpPostRpc(client: DaemonRpcClient, path: string, jsonBody: JsonNode, resultType: typedesc) =
  # setup request
  if client.digestAuthEnabled:
    client.httpClient.headers = newHttpHeaders({ 
      "Content-Type": "application/json",
      "Authorization": client.getDigestAuthHeader(path) 
    })
  else:
    client.httpClient.headers = newHttpHeaders({ 
      "Content-Type": "application/json",
    })

  when not path.startsWith("/"):
    {.error: "Path " & path & " has to start with a slash ('/')"}
  
  let response = client.httpClient.request(client.connectionString & path, httpMethod = HttpPost, body = $jsonBody)
  if response.status != "200 Ok":
    raise newException(HttpError, "RPC call returned non-200 HTTP code " & response.status)

  # if a result is expected, parse json into result class, else just return an empty result
  when resultType is not EmptyResponse:
    let data = parseJson(response.body).to(resultType)
  else:
    let data = EmptyResponse()

  result = RpcCallResult[resultType](
    rawBody: response.body,
    statusCode: response.status,
    data: data,
    ok: true,
    error: RpcError(code: 0, message: ""),
  )

# ===== Monero Wallet RPC calls ======
# see https://www.getmonero.org/resources/developer-guides/wallet-rpc.html#get_address

proc setDaemon*(client: WalletRpcClient, params: SetDaemonRequest): RpcCallResult[EmptyResponse] =
  ## Connect the RPC server to a Monero daemon.
  client.doJsonRpc("set_daemon", %*params, EmptyResponse)

proc getBalance*(client: WalletRpcClient, params: GetBalanceRequest): RpcCallResult[GetBalanceResponse] =
  ## Return the wallet's balance.
  client.doJsonRpc("get_balance", %*params, GetBalanceResponse)

proc getAddress*(client: WalletRpcClient, params: GetAddressRequest): RpcCallResult[GetAddressResponse] =
  ## Return the wallet's addresses for an account. Optionally filter for specific set of subaddresses.
  client.doJsonRpc("get_address", %*params, GetAddressResponse)

proc getAddressIndex*(client: WalletRpcClient, params: GetAddressIndexRequest): RpcCallResult[GetAddressIndexResponse] =
  ## Get account and address indexes from a specific (sub)address
  client.doJsonRpc("get_address_index", %*params, GetAddressIndexResponse)

proc createAddress*(client: WalletRpcClient, params: CreateAddressRequest): RpcCallResult[CreateAddressResponse] =
  ## Create a new address for an account. Optionally, label the new address.
  client.doJsonRpc("create_address", %*params, CreateAddressResponse)

proc labelAddress*(client: WalletRpcClient, params: LabelAddressRequest): RpcCallResult[EmptyResponse] =
  ## Label an address.
  client.doJsonRpc("label_address", %*params, EmptyResponse)

proc validateAddress*(client: WalletRpcClient, params: ValidateAddressRequest): RpcCallResult[ValidateAddressResponse] =
  ## Analyzes a string to determine whether it is a valid monero wallet address and returns the result and the address specifications.
  client.doJsonRpc("validate_address", %*params, ValidateAddressResponse)

proc getAccounts*(client: WalletRpcClient, params: GetAccountsRequest): RpcCallResult[GetAccountsResponse] =
  ## Get all accounts for a wallet. Optionally filter accounts by tag.
  client.doJsonRpc("get_accounts", %*params, GetAccountsResponse)

proc createAccount*(client: WalletRpcClient, params: CreateAccountRequest): RpcCallResult[CreateAccountResponse] =
  ## Create a new account with an optional label.
  client.doJsonRpc("create_account", %*params, CreateAccountResponse)

proc labelAccount*(client: WalletRpcClient, params: LabelAccountRequest): RpcCallResult[EmptyResponse] =
  ## Label an account.
  client.doJsonRpc("label_account", %*params, EmptyResponse)

proc getAccountTags*(client: WalletRpcClient): RpcCallResult[GetAccountTagsResponse] =
  ## Get a list of user-defined account tags.
  client.doJsonRpc("get_account_tags", %*{}, GetAccountTagsResponse)

proc tagAccounts*(client: WalletRpcClient, params: TagAccountsRequest): RpcCallResult[EmptyResponse] =
  ## Apply a filtering tag to a list of accounts.
  client.doJsonRpc("tag_accounts", %*params, EmptyResponse)

proc untagAccounts*(client: WalletRpcClient, params: UntagAccountsRequest): RpcCallResult[EmptyResponse] =
  ## Remove filtering tag from a list of accounts.
  client.doJsonRpc("untag_accounts", %*params, EmptyResponse)

proc setAccountTagDescription*(client: WalletRpcClient, params: SetAccountTagDescriptionRequest): RpcCallResult[EmptyResponse] =
  ## Set description for an account tag.
  client.doJsonRpc("set_account_tag_description", %*params, EmptyResponse)

proc getHeight*(client: WalletRpcClient): RpcCallResult[GetHeightResponse] =
  ## Returns the wallet's current block height.
  client.doJsonRpc("get_height", %*{}, GetHeightResponse)

proc transfer*(client: WalletRpcClient, params: TransferRequest): RpcCallResult[TransferResponse] =
  ## Send monero to a number of recipients.
  client.doJsonRpc("transfer", %*params, TransferResponse)

proc transferSplit*(client: WalletRpcClient, params: TransferSplitRequest): RpcCallResult[TransferSplitResponse] =
  ## Same as transfer, but can split into more than one tx if necessary.
  client.doJsonRpc("transfer_split", %*params, TransferSplitResponse)

proc signTransfer*(client: WalletRpcClient, params: SignTransferRequest): RpcCallResult[SignTransferResponse] =
  ## Sign a transaction created on a read-only wallet (in cold-signing process)
  client.doJsonRpc("sign_transfer", %*params, SignTransferResponse)

proc submitTransfer*(client: WalletRpcClient, params: SubmitTransferRequest): RpcCallResult[SubmitTransferResponse] =
  ## Submit a previously signed transaction on a read-only wallet (in cold-signing process).
  client.doJsonRpc("submit_transfer", %*params, SubmitTransferResponse)

proc sweepDust*(client: WalletRpcClient, params: SweepDustRequest): RpcCallResult[SweepDustResponse] =
  ## Send all dust outputs back to the wallet's, to make them easier to spend (and mix).
  client.doJsonRpc("sweep_dust", %*params, SweepDustResponse)

proc sweepAll*(client: WalletRpcClient, params: SweepAllRequest): RpcCallResult[SweepAllResponse] =
  ## Send all unlocked balance to an address.
  client.doJsonRpc("sweep_all", %*params, SweepAllResponse)

proc sweepSingle*(client: WalletRpcClient, params: SweepSingleRequest): RpcCallResult[SweepSingleResponse] =
  ## Send all of a specific unlocked output to an address.
  client.doJsonRpc("sweep_single", %*params, SweepSingleResponse)

proc relayTx*(client: WalletRpcClient, params: RelayTxRequest): RpcCallResult[RelayTxResponse] =
  ## Relay a transaction previously created with `"do_not_relay":true`.
  client.doJsonRpc("relay_tx", %*params, RelayTxResponse)

proc store*(client: WalletRpcClient): RpcCallResult[EmptyResponse] =
  ## Save the wallet file.
  client.doJsonRpc("store", %*{}, EmptyResponse)

proc getPayments*(client: WalletRpcClient, params: GetPaymentsRequest): RpcCallResult[GetPaymentsResponse] =
  ## Get a list of incoming payments using a given payment id.
  client.doJsonRpc("get_payments", %*params, GetPaymentsResponse)

proc getBulkPayments*(client: WalletRpcClient, params: GetBulkPaymentsRequest): RpcCallResult[GetBulkPaymentsResponse] =
  ## Get a list of incoming payments using a given payment id, or a list of payments ids, from a given height.
  ## This method is the preferred method over `get_payments` because it has the same functionality but is more extendable. 
  ## Either is fine for looking up transactions by a single payment ID.
  client.doJsonRpc("get_bulk_payments", %*params, GetBulkPaymentsResponse)

proc incomingTransfers*(client: WalletRpcClient, params: IncomingTransfersRequest): RpcCallResult[IncomingTransfersResponse] =
  ## Return a list of incoming transfers to the wallet.
  client.doJsonRpc("incoming_transfers", %*params, IncomingTransfersResponse)

proc queryKey*(client: WalletRpcClient, params: QueryKeyRequest): RpcCallResult[QueryKeyResponse] =
  ## Return the spend or view private key.
  client.doJsonRpc("query_key", %*params, QueryKeyResponse)

proc makeIntegratedAddress*(client: WalletRpcClient, params: MakeIntegratedAddressRequest): RpcCallResult[MakeIntegratedAddressResponse] =
  ## Make an integrated address from the wallet address and a payment id.
  client.doJsonRpc("make_integrated_address", %*params, MakeIntegratedAddressResponse)

proc splitIntegratedAddress*(client: WalletRpcClient, params: SplitIntegratedAddressRequest): RpcCallResult[SplitIntegratedAddressResponse] =
  ## Retrieve the standard address and payment id corresponding to an integrated address.
  client.doJsonRpc("split_integrated_address", %*params, SplitIntegratedAddressResponse)

proc stopWallet*(client: WalletRpcClient): RpcCallResult[EmptyResponse] =
  ## Stops the wallet, storing the current state.
  client.doJsonRpc("stop_wallet", %*{}, EmptyResponse)

proc rescanBlockchain*(client: WalletRpcClient): RpcCallResult[EmptyResponse] =
  ## Rescan the blockchain from scratch, losing any information which can not be recovered from the blockchain itself.
  ## This includes destination addresses, tx secret keys, tx notes, etc.
  client.doJsonRpc("rescan_blockchain", %*{}, EmptyResponse)

proc setTxNotes*(client: WalletRpcClient, params: SetTxNotesRequest): RpcCallResult[EmptyResponse] =
  ## Set arbitrary string notes for transactions.
  client.doJsonRpc("set_tx_notes", %*params, EmptyResponse)

proc getTxNotes*(client: WalletRpcClient, params: GetTxNotesRequest): RpcCallResult[GetTxNotesResponse] =
  ## Get string notes for transactions.
  client.doJsonRpc("get_tx_notes", %*params, GetTxNotesResponse)

proc setAttribute*(client: WalletRpcClient, params: SetAttributeRequest): RpcCallResult[EmptyResponse] =
  ## Set arbitrary attribute.
  client.doJsonRpc("set_attribute", %*params, EmptyResponse)

proc getAttribute*(client: WalletRpcClient, params: GetAttributeRequest): RpcCallResult[GetAttributeResponse] =
  ## Get attribute value by name.
  client.doJsonRpc("get_attribute", %*params, GetAttributeResponse)

proc getTxKey*(client: WalletRpcClient, params: GetTxKeyRequest): RpcCallResult[GetTxKeyResponse] =
  ## Get transaction secret key from transaction id.
  client.doJsonRpc("get_tx_key", %*params, GetTxKeyResponse)

proc checkTxKey*(client: WalletRpcClient, params: CheckTxKeyRequest): RpcCallResult[CheckTxKeyResponse] =
  ## Check a transaction in the blockchain with its secret key.
  client.doJsonRpc("check_tx_key", %*params, CheckTxKeyResponse)

proc getTxProof*(client: WalletRpcClient, params: GetTxProofRequest): RpcCallResult[GetTxProofResponse] =
  ## Get transaction signature to prove it.
  client.doJsonRpc("get_tx_proof", %*params, GetTxProofResponse)

proc checkTxProof*(client: WalletRpcClient, params: CheckTxProofRequest): RpcCallResult[CheckTxProofResponse] =
  ## Prove a transaction by checking its signature.
  client.doJsonRpc("check_tx_proof", %*params, CheckTxProofResponse)

proc getSpendProof*(client: WalletRpcClient, params: GetSpendProofRequest): RpcCallResult[GetSpendProofResponse] =
  ## Generate a signature to prove a spend. Unlike proving a transaction, it does not requires the destination public address.
  client.doJsonRpc("get_spend_proof", %*params, GetSpendProofResponse)

proc checkSpendProof*(client: WalletRpcClient, params: CheckSpendProofRequest): RpcCallResult[CheckSpendProofResponse] =
  ## Prove a spend using a signature. Unlike proving a transaction, it does not requires the destination public address.
  client.doJsonRpc("check_spend_proof", %*params, CheckSpendProofResponse)

proc getReserveProof*(client: WalletRpcClient, params: GetReserveProofRequest): RpcCallResult[GetReserveProofResponse] =
  ## Generate a signature to prove of an available amount in a wallet.
  client.doJsonRpc("get_reserve_proof", %*params, GetReserveProofResponse)

proc checkReserveProof*(client: WalletRpcClient, params: CheckReserveProofRequest): RpcCallResult[CheckReserveProofResponse] =
  ## Proves a wallet has a disposable reserve using a signature.
  client.doJsonRpc("check_reserve_proof", %*params, CheckReserveProofResponse)

proc getTransfers*(client: WalletRpcClient, params: GetTransfersRequest): RpcCallResult[GetTransfersResponse] =
  ## Returns a list of transfers.
  client.doJsonRpc("get_transfers", %*params, GetTransfersResponse)

proc getTransferByTxid*(client: WalletRpcClient, params: GetTransferByTxidRequest): RpcCallResult[GetTransferByTxidResponse] =
  ## Show information about a transfer to/from this address.
  client.doJsonRpc("get_transfer_by_txid", %*params, GetTransferByTxidResponse)

proc describeTransfer*(client: WalletRpcClient, params: DescribeTransferRequest): RpcCallResult[DescribeTransferResponse] =
  ## Returns details for each transaction in an unsigned or multisig transaction set. 
  ## Transaction sets are obtained as return values from one of the following RPC methods:
  client.doJsonRpc("describe_transfer", %*params, DescribeTransferResponse)

proc sign*(client: WalletRpcClient, params: SignRequest): RpcCallResult[SignResponse] =
  ## Sign a string.
  client.doJsonRpc("sign", %*params, SignResponse)

proc verify*(client: WalletRpcClient, params: VerifyRequest): RpcCallResult[VerifyResponse] =
  ## Verify a signature on a string.
  client.doJsonRpc("verify", %*params, VerifyResponse)

proc exportOutputs*(client: WalletRpcClient, params: ExportOutputsRequest): RpcCallResult[ExportOutputsResponse] =
  ## Export outputs in hex format.
  client.doJsonRpc("export_outputs", %*params, ExportOutputsResponse)

proc importOutputs*(client: WalletRpcClient, params: ImportOutputsRequest): RpcCallResult[ImportOutputsResponse] =
  ## Import outputs in hex format.
  client.doJsonRpc("import_outputs", %*params, ImportOutputsResponse)

proc exportKeyImages*(client: WalletRpcClient, params: ExportKeyImagesRequest): RpcCallResult[ExportKeyImagesResponse] =
  ## Export a signed set of key images.
  client.doJsonRpc("export_key_images", %*params, ExportKeyImagesResponse)

proc importKeyImages*(client: WalletRpcClient, params: ImportKeyImagesRequest): RpcCallResult[ImportKeyImagesResponse] =
  ## Import signed key images list and verify their spent status.
  client.doJsonRpc("import_key_images", %*params, ImportKeyImagesResponse)

proc makeUri*(client: WalletRpcClient, params: MakeUriRequest): RpcCallResult[MakeUriResponse] =
  ## Create a payment URI using the official URI spec.
  client.doJsonRpc("make_uri", %*params, MakeUriResponse)

proc parseUri*(client: WalletRpcClient, params: ParseUriRequest): RpcCallResult[ParseUriResponse] =
  ## Parse a payment URI to get payment information.
  client.doJsonRpc("parse_uri", %*params, ParseUriResponse)

proc getAddressBook*(client: WalletRpcClient, params: GetAddressBookRequest): RpcCallResult[GetAddressBookResponse] =
  ## Retrieves entries from the address book.
  client.doJsonRpc("get_address_book", %*params, GetAddressBookResponse)

proc addAddressBook*(client: WalletRpcClient, params: AddAddressBookRequest): RpcCallResult[AddAddressBookResponse] =
  ## Add an entry to the address book.
  client.doJsonRpc("add_address_book", %*params, AddAddressBookResponse)

proc editAddressBook*(client: WalletRpcClient, params: EditAddressBookRequest): RpcCallResult[EmptyResponse] =
  ## Edit an existing address book entry.
  client.doJsonRpc("edit_address_book", %*params, EmptyResponse)

proc deleteAddressBook*(client: WalletRpcClient, params: DeleteAddressBookRequest): RpcCallResult[EmptyResponse] =
  ## Delete an entry from the address book.
  client.doJsonRpc("delete_address_book", %*params, EmptyResponse)

proc refresh*(client: WalletRpcClient, params: RefreshRequest): RpcCallResult[RefreshResponse] =
  ## Refresh a wallet after opening.
  client.doJsonRpc("refresh", %*params, RefreshResponse)

proc autoRefresh*(client: WalletRpcClient, params: AutoRefreshRequest): RpcCallResult[EmptyResponse] =
  ## Set whether and how often to automatically refresh the current wallet.
  client.doJsonRpc("auto_refresh", %*params, EmptyResponse)

proc rescanSpent*(client: WalletRpcClient): RpcCallResult[EmptyResponse] =
  ## Rescan the blockchain for spent outputs.
  client.doJsonRpc("rescan_spent", %*{}, EmptyResponse)

proc startMining*(client: WalletRpcClient, params: StartMiningRequest): RpcCallResult[EmptyResponse] =
  ## Start mining in the Monero daemon.
  client.doJsonRpc("start_mining", %*params, EmptyResponse)

proc stopMining*(client: WalletRpcClient): RpcCallResult[EmptyResponse] =
  ## Stop mining in the Monero daemon.
  client.doJsonRpc("stop_mining", %*{}, EmptyResponse)

proc getLanguages*(client: WalletRpcClient): RpcCallResult[GetLanguagesResponse] =
  ## Get a list of available languages for your wallet's seed.
  client.doJsonRpc("get_languages", %*{}, GetLanguagesResponse)

proc createWallet*(client: WalletRpcClient, params: CreateWalletRequest): RpcCallResult[EmptyResponse] =
  ## Create a new wallet. 
  ## You need to have set the argument `--wallet-dir` when launching monero-wallet-rpc to make this work.
  client.doJsonRpc("create_wallet", %*params, EmptyResponse)

proc generateFromKeys*(client: WalletRpcClient, params: GenerateFromKeysRequest): RpcCallResult[GenerateFromKeysResponse] =
  ## Restores a wallet from a given wallet address, view key, and optional spend key.
  client.doJsonRpc("generate_from_keys", %*params, GenerateFromKeysResponse)

proc openWallet*(client: WalletRpcClient, params: OpenWalletRequest): RpcCallResult[EmptyResponse] =
  ## Open a wallet. 
  ## You need to have set the argument `--wallet-dir` when launching monero-wallet-rpc to make this work.
  client.doJsonRpc("open_wallet", %*params, EmptyResponse)

proc restoreDeterministicWallet*(client: WalletRpcClient, params: RestoreDeterministicWalletRequest): RpcCallResult[RestoreDeterministicWalletResponse] =
  ## Create and open a wallet on the RPC server from an existing mnemonic phrase and close the currently open wallet.
  client.doJsonRpc("restore_deterministic_wallet", %*params, RestoreDeterministicWalletResponse)

proc closeWallet*(client: WalletRpcClient): RpcCallResult[EmptyResponse] =
  ## Close the currently opened wallet, after trying to save it.
  client.doJsonRpc("close_wallet", %*{}, EmptyResponse)

proc changeWalletPassword*(client: WalletRpcClient, params: ChangeWalletPasswordRequest): RpcCallResult[EmptyResponse] =
  ## Change a wallet password.
  client.doJsonRpc("change_wallet_password", %*params, EmptyResponse)

proc isMultisig*(client: WalletRpcClient): RpcCallResult[IsMultisigResponse] =
  ## Check if a wallet is a multisig one.
  client.doJsonRpc("is_multisig", %*{}, IsMultisigResponse)

proc prepareMultisig*(client: WalletRpcClient): RpcCallResult[PrepareMultisigResponse] =
  ## Prepare a wallet for multisig by generating a multisig string to share with peers.
  client.doJsonRpc("prepare_multisig", %*{}, PrepareMultisigResponse)

proc makeMultisig*(client: WalletRpcClient, params: MakeMultisigRequest): RpcCallResult[MakeMultisigResponse] =
  ## Make a wallet multisig by importing peers multisig string.
  client.doJsonRpc("make_multisig", %*params, MakeMultisigResponse)

proc exportMultisigInfo*(client: WalletRpcClient): RpcCallResult[ExportMultisigInfoResponse] =
  ## Export multisig info for other participants.
  client.doJsonRpc("export_multisig_info", %*{}, ExportMultisigInfoResponse)

proc importMultisigInfo*(client: WalletRpcClient, params: ImportMultisigInfoRequest): RpcCallResult[ImportMultisigInfoResponse] =
  ## Import multisig info from other participants.
  client.doJsonRpc("import_multisig_info", %*params, ImportMultisigInfoResponse)

proc finalizeMultisig*(client: WalletRpcClient, params: FinalizeMultisigRequest): RpcCallResult[FinalizeMultisigResponse] =
  ## Turn this wallet into a multisig wallet, extra step for N-1/N wallets.
  client.doJsonRpc("finalize_multisig", %*params, FinalizeMultisigResponse)

proc signMultisig*(client: WalletRpcClient, params: SignMultisigRequest): RpcCallResult[SignMultisigResponse] =
  ## Sign a transaction in multisig.
  client.doJsonRpc("sign_multisig", %*params, SignMultisigResponse)

proc submitMultisig*(client: WalletRpcClient, params: SubmitMultisigRequest): RpcCallResult[SubmitMultisigResponse] =
  ## Submit a signed multisig transaction.
  client.doJsonRpc("submit_multisig", %*params, SubmitMultisigResponse)

proc exchangeMultisigKeys*(client: WalletRpcClient, params: ExchangeMultisigKeysRequest): RpcCallResult[ExchangeMultisigKeysResponse] =
  ## Performs extra multisig keys exchange rounds. Needed for arbitrary M/N multisig wallets
  client.doJsonRpc("exchange_multisig_keys", %*params, ExchangeMultisigKeysResponse)

proc getVersion*(client: WalletRpcClient): RpcCallResult[GetVersionResponse] =
  ## Get RPC version Major & Minor integer-format, where Major is the first 16 bits and Minor the last 16 bits.
  client.doJsonRpc("get_version", %*{}, GetVersionResponse)

proc scanTx*(client: WalletRpcClient, params: ScanTxRequest): RpcCallResult[EmptyResponse] =
  ## Scan for list of transaction ids. Introduced in v0.18.0.0 Fluorine Fermi
  client.doJsonRpc("scan_tx", %*params, EmptyResponse)

proc freeze*(client: WalletRpcClient, params: FreezeRequest): RpcCallResult[EmptyResponse] =
  ## Freeze a single output by key image so it will not be used
  client.doJsonRpc("freeze", %*params, EmptyResponse)

proc frozen*(client: WalletRpcClient, params: FrozenRequest): RpcCallResult[FrozenResponse] =
  ## Checks whether a given output is currently frozen by key image
  client.doJsonRpc("frozen", %*params, FrozenResponse)

proc thaw*(client: WalletRpcClient, params: ThawRequest): RpcCallResult[EmptyResponse] =
  ## Thaw a single output by key image so it may be used again
  client.doJsonRpc("thaw", %*params, EmptyResponse)

proc estimateTxSizeAndWeight*(client: WalletRpcClient, params: EstimateTxSizeAndWeightRequest): RpcCallResult[EstimateTxSizeAndWeightResponse] =
  ## Estimate size and weight of a transaction
  client.doJsonRpc("estimate_tx_size_and_weight", %*params, EstimateTxSizeAndWeightResponse)

# ===== Monero Daemon RPC calls ======
# see https://www.getmonero.org/resources/developer-guides/daemon-rpc.html

proc getBlockCount*(client: DaemonRpcClient): RpcCallResult[GetBlockCountResponse] =
  ## Look up how many blocks are in the longest chain known to the node.
  client.doJsonRpc("get_block_count", %*{}, GetBlockCountResponse)

proc onGetBlockHash*(client: DaemonRpcClient, params: OnGetBlockHashRequest): RpcCallResult[OnGetBlockHashResponse] =
  ## Look up a block's hash by its height.
  client.doJsonRpc("on_get_block_hash", %*params, OnGetBlockHashResponse)
  
proc getBlockTemplate*(client: DaemonRpcClient, params: GetBlockTemplateRequest): RpcCallResult[GetBlockTemplateResponse] =
  ## Get a block template on which mining a new block. 
  client.doJsonRpc("get_block_template", %*params, GetBlockTemplateResponse)

proc submitBlock*(client: DaemonRpcClient, params: SubmitBlockRequest): RpcCallResult[SubmitBlockResponse] =
  ## Submit a mined block to the network.
  client.doJsonRpc("submit_block", %*params, SubmitBlockResponse)

proc getLastBlockHeader*(client: DaemonRpcClient): RpcCallResult[GetLastBlockHeaderResponse] =
  ## Block header information for the most recent block is easily retrieved with this method. No inputs are needed.
  client.doJsonRpc("get_last_block_header", %*{}, GetLastBlockHeaderResponse)

proc getBlockHeaderByHash*(client: DaemonRpcClient, params: GetBlockHeaderByHashRequest): RpcCallResult[GetBlockHeaderByHashResponse] =
  ## Block header information can be retrieved using either a block's hash or height. This method includes a block's hash as an input parameter to retrieve basic information about the block.
  client.doJsonRpc("get_block_header_by_hash", %*params, GetBlockHeaderByHashResponse)

proc getBlockHeaderByHeight*(client: DaemonRpcClient, params: GetBlockHeaderByHeightRequest): RpcCallResult[GetBlockHeaderByHeightResponse] =
  ## Block header information can be retrieved using either a block's hash or height. This method includes a block's height as an input parameter to retrieve basic information about the block.
  client.doJsonRpc("get_block_header_by_height", %*params, GetBlockHeaderByHeightResponse)

proc getBlockHeadersRange*(client: DaemonRpcClient, params: GetBlockHeadersRangeRequest): RpcCallResult[GetBlockHeadersRangeResponse] =
  ## Similar to get_block_header_by_height, but for a range of blocks. This method includes a starting block height and an ending block height as parameters to retrieve basic information about the range of blocks.
  client.doJsonRpc("get_block_headers_range", %*params, GetBlockHeadersRangeResponse)

proc getBlock*(client: DaemonRpcClient, params: GetBlockRequest): RpcCallResult[GetBlockResponse] = 
  ## Full block information can be retrieved by either block height or hash, like with the above block header calls. For full block information, both lookups use the same method, but with different input parameters.
  client.doJsonRpc("get_block", %*params, GetBlockResponse)

proc getConnections*(client: DaemonRpcClient): RpcCallResult[GetConnectionsResponse] =
  ## Retrieve information about incoming and outgoing connections to your node.
  client.doJsonRpc("get_connections", %*{}, GetConnectionsResponse)

proc getInfo*(client: DaemonRpcClient): RpcCallResult[GetInfoResponse] = 
  ## Retrieve general information about the state of your node and the network.
  client.doJsonRpc("get_info", %*{}, GetInfoResponse)

proc hardForkInfo*(client: DaemonRpcClient): RpcCallResult[HardForkInfoResponse] = 
  ## Look up information regarding hard fork voting and readiness.
  client.doJsonRpc("hard_fork_info", %*{}, HardForkInfoResponse)

proc setBans*(client: DaemonRpcClient, params: SetBansRequest): RpcCallResult[SetBansResponse] =
  ## Ban another node by IP or host.
  client.doJsonRpc("set_bans", %*params, SetBansResponse)

proc getBans*(client: DaemonRpcClient): RpcCallResult[GetBansResponse] = 
  ## Get list of banned IPs.
  client.doJsonRpc("get_bans", %*{}, GetBansResponse)

proc flushTxPool*(client: DaemonRpcClient, params: FlushTxPoolRequest): RpcCallResult[FlushTxPoolResponse] =
  ## Flush tx ids from transaction pool
  client.doJsonRpc("flush_txpool", %*params, FlushTxPoolResponse)

proc getOutputHistogram*(client: DaemonRpcClient, params: GetOutputHistogramRequest): RpcCallResult[GetOutputHistogramResponse] =
  ## Get a histogram of output amounts. For all amounts (possibly filtered by parameters), gives the number of outputs on the chain for that amount. RingCT outputs counts as 0 amount.
  client.doJsonRpc("get_output_histogram", %*params, GetOutputHistogramResponse)

proc getCoinbaseTxSum*(client: DaemonRpcClient, params: GetCoinbaseTxSumRequest): RpcCallResult[GetCoinbaseTxSumResponse] =
  ## Get the coinbase amount and the fees amount for n last blocks starting at particular height
  client.doJsonRpc("get_coinbase_tx_sum", %*params, GetCoinbaseTxSumResponse)

proc getVersion*(client: DaemonRpcClient): RpcCallResult[GetVersionResponse_Daemon] =
  ## Give the node current version
  client.doJsonRpc("get_version", %*{}, GetVersionResponse_Daemon)

proc getFeeEstimate*(client: DaemonRpcClient, params: GetFeeEstimateRequest): RpcCallResult[GetFeeEstimateResponse] =
  ## Gives an estimation on fees per byte.
  client.doJsonRpc("get_fee_estimate", %*params, GetFeeEstimateResponse)

proc getAlternateChains*(client: DaemonRpcClient): RpcCallResult[GetAlternateChainsResponse] = 
  ## Display alternative chains seen by the node.
  client.doJsonRpc("get_alternate_chains", %*{}, GetAlternateChainsResponse)

proc relayTx*(client: DaemonRpcClient, params: RelayTxRequest_Daemon): RpcCallResult[RelayTxResponse_Daemon] =
  ## Relay a list of transaction IDs.
  client.doJsonRpc("relay_tx", %*params, RelayTxResponse_Daemon)

proc syncInfo*(client: DaemonRpcClient): RpcCallResult[SyncInfoResponse] = 
  ## Get synchronisation informations
  client.doJsonRpc("sync_info", %*{}, SyncInfoResponse)

proc getTxpoolBacklog*(client: DaemonRpcClient): RpcCallResult[GetTxpoolBacklogResponse] =
  ## Get all transaction pool backlog
  client.doJsonRpc("get_txpool_backlog", %*{}, GetTxpoolBacklogResponse)

proc getOutputDistribution*(client: DaemonRpcClient, params: GetOutputDistributionRequest): RpcCallResult[GetOutputDistributionResponse] =
  ## Get output distribution.
  client.doJsonRpc("get_output_distribution", %*params, GetOutputDistributionResponse)

proc getHeight*(client: DaemonRpcClient): RpcCallResult[GetHeightResponse_Daemon] =
  ## Get the node's current height.
  client.doHttpGetRpc("/get_height", GetHeightResponse_Daemon)

proc getTransactions*(client: DaemonRpcClient, params: GetTransactionsRequest): RpcCallResult[GetTransactionsResponse] =
  ## Look up one or more transactions by hash.
  client.doHttpPostRpc("/get_transactions", %*params, GetTransactionsResponse)

proc getAltBlockHashes*(client: DaemonRpcClient): RpcCallResult[GetAltBlockHashesResponse] =
  ## Get the known blocks hashes which are not on the main chain.
  client.doHttpGetRpc("/get_alt_blocks_hashes", GetAltBlockHashesResponse)

proc isKeyImageSpent*(client: DaemonRpcClient, params: IsKeyImageSpentRequest): RpcCallResult[IsKeyImageSpentResponse] =
  ## Check if outputs have been spent using the key image associated with the output.
  client.doHttpPostRpc("/is_key_image_spent", %*params, IsKeyImageSpentResponse)

proc sendRawTransaction*(client: DaemonRpcClient, params: SendRawTransactionRequest): RpcCallResult[SendRawTransactionResponse] =
  ## Broadcast a raw transaction to the network.
  client.doHttpPostRpc("/send_raw_transaction", %*params, SendRawTransactionResponse)

proc startMining*(client: DaemonRpcClient, params: StartMiningRequest_Daemon): RpcCallResult[StartMiningResponse] =
  ## Start mining on the daemon.
  client.doHttpPostRpc("/start_mining", %*params, StartMiningResponse)

proc stopMining*(client: DaemonRpcClient): RpcCallResult[StopMiningResponse] = 
  ## Stop mining on the daemon._
  client.doHttpGetRpc("/stop_mining", StopMiningResponse)

proc miningStatus*(client: DaemonRpcClient): RpcCallResult[MiningStatusResponse] = 
  ## Get the mining status of the daemon.
  client.doHttpGetRpc("/mining_status", MiningStatusResponse)

proc saveBc*(client: DaemonRpcClient): RpcCallResult[SaveBcResponse] = 
  ## Save the blockchain. The blockchain does not need saving and is always saved when modified, however it does a sync to flush the filesystem cache onto the disk for safety purposes against Operating System or Hardware crashes.
  client.doHttpGetRpc("/save_bc", SaveBcResponse)

proc getPeerList*(client: DaemonRpcClient): RpcCallResult[GetPeerListResponse] =
  ## Get the known peers list.
  client.doHttpGetRpc("/get_peer_list", GetPeerListResponse)

proc setLogHashRate*(client: DaemonRpcClient, params: SetLogHashRateRequest): RpcCallResult[SetLogHashRateResponse] = 
  ## Set the log hash rate display mode.
  client.doHttpPostRpc("/set_log_hash_rate", %*params, SetLogHashRateResponse)

proc setLogLevel*(client: DaemonRpcClient, params: SetLogLevelRequest): RpcCallResult[SetLogLevelResponse] =
  ## Set the daemon log level. By default, log level is set to 0.
  client.doHttpPostRpc("/set_log_level", %*params, SetLogLevelResponse)

proc setLogCategories*(client: DaemonRpcClient, params: SetLogCategoriesRequest): RpcCallResult[SetLogCategoriesResponse] =
  ## Set the daemon log categories. Categories are represented as a comma separated list of <Category>:<level> (similarly to syslog standard <Facility>:<Severity-level>), where:
  client.doHttpPostRpc("/set_log_categories", %*params, SetLogCategoriesResponse)

proc getTransactionPool*(client: DaemonRpcClient): RpcCallResult[GetTransactionPoolResponse] = 
  ## Show information about valid transactions seen by the node but not yet mined into a block, as well as spent key image information for the txpool in the node's memory.
  client.doHttpGetRpc("/get_transaction_pool", GetTransactionPoolResponse)

proc getTransactionPoolStats*(client: DaemonRpcClient): RpcCallResult[GetTransactionPoolStatsResponse] = 
  ## Get the transaction pool statistics.
  client.doHttpGetRpc("/get_transaction_pool_stats", GetTransactionPoolStatsResponse)

proc stopDaemon*(client: DaemonRpcClient): RpcCallResult[StopDaemonResponse] =
  ## Send a command to the daemon to safely disconnect and shut down.
  client.doHttpGetRpc("/stop_daemon", StopDaemonResponse)

proc getLimit*(client: DaemonRpcClient): RpcCallResult[GetLimitResponse] = 
  ## Get daemon bandwidth limits.
  client.doHttpGetRpc("/get_limit", GetLimitResponse)

proc setLimit*(client: DaemonRpcClient, params: SetLimitRequest): RpcCallResult[SetLimitResponse] =
  ## Set daemon bandwidth limits.
  client.doHttpPostRpc("/set_limit", %*params, SetLimitResponse)

proc outPeers*(client: DaemonRpcClient, params: OutPeersRequest): RpcCallResult[OutPeersResponse] =
  ## Limit number of Outgoing peers.
  client.doHttpPostRpc("/out_peers", %*params, OutPeersResponse)

proc inPeers*(client: DaemonRpcClient, params: InPeersRequest): RpcCallResult[InPeersResponse] =
  ## Limit number of incoming peers.
  client.doHttpPostRpc("/in_peers", %*params, InPeersResponse)

proc getOuts*(client: DaemonRpcClient, params: GetOutsRequest): RpcCallResult[GetOutsResponse] = 
  ## Get outputs.
  client.doHttpPostRpc("/get_outs", %*params, GetOutsResponse)

proc update*(client: DaemonRpcClient, params: UpdateRequest): RpcCallResult[UpdateResponse] = 
  ## Update daemon.
  client.doHttpGetRpc("/update", UpdateResponse)
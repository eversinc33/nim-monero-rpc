import unittest
import monerorpc, options

suite "monero daemon rpc":
  echo "Running tests for daemon"
  echo "Make sure you are running a monero-daemon-rpc server on 127.0.0.1:18081 with --rpc-login monero:password (see README)."
  echo "====================================================="

  test "Call get_version":
    let client = newDaemonRpcClient()
    let r = client.getVersion()
    check r.ok

  test "Call /get_height":
    let client = newDaemonRpcClient()
    let r = client.getHeight()
    check r.data.status == "OK"
    check r.ok

  test "Call /start_mining":
    let client = newDaemonRpcClient()
    let r = client.startMining(
      StartMiningRequest_Daemon(
        do_background_mining: false,
        ignore_battery: false,
        miner_address: "TEST",
        threads_count: 1
      )
    )
    check r.ok
    check r.data.status == "Failed, wrong address"

suite "monero wallet rpc":
  echo "Running tests for wallet"
  echo "Make sure you are running a monero-wallet-rpc server on 127.0.0.1:18082 with --rpc-login monero:password (see README)."
  echo "====================================================="

  test "Call set_daemon with digest auth":
    let client = newWalletRpcClient(password="password", username="monero")
    let res = client.setDaemon(
      SetDaemonRequest(
        address: some("http://node.supportxmr.com:18081"),
        trusted: some(false)
      )
    )
    check res.ok

  test "Call get_balance with digest auth":
    let client = newWalletRpcClient(password="password", username="monero")
    let r = client.getBalance(
        GetBalanceRequest()
    )
    echo "[*] Current balance: " & $r.data.balance & "XMR"
    check r.ok

  test "Call get_version with digest auth":
    let client = newWalletRpcClient(password="password", username="monero")
    let r = client.getVersion()
    check r.ok

  test "Call make_integrated_address with digest auth":
    let client = newWalletRpcClient(password="password", username="monero")
    let r = client.makeIntegratedAddress(
      MakeIntegratedAddressRequest()
    )
    # length of integrated address should be 16 by default
    check r.data.payment_id.len == 16
    check r.ok

  test "Call get_tx_notes and supply wrong formatted txid (test for error)":
    let client = newWalletRpcClient(password="password", username="monero")
    let r = client.getTxNotes(
      GetTxNotesRequest(txids: @["wrongformat"])
    )
    echo $r.error
    check r.ok == false

  test "Example code from README":
    let client = newWalletRpcClient(password="password", username="monero")
    let balanceRequest = client.getBalance(GetBalanceRequest())
    echo "[*] Current balance: " & $balanceRequest.data.balance
    echo balanceRequest.rawBody
    echo "[*] Creating new address"
    let createAddressRequest = client.createAddress(
        CreateAddressRequest(
            accountIndex: 0,
            label: some("my new address") 
        )
    )
    if createAddressRequest.ok:
        echo "[*] Created new address at " & createAddressRequest.data.address
    else:
        echo "[!] Failed with error code " & $createAddressRequest.error.code
        echo "[*] " & createAddressRequest.error.message 
    
  test "call get_transfers with digest auth":
    let client = newWalletRpcClient(password="password", username="monero")
    let getTransfersRequest = client.getTransfers(GetTransfersRequest(
        `in`: true,
        `out`: false,
        pending: false,
        failed: false,
        pool: false
    ))
    check getTransfersRequest.ok

  test "Call estimate_tx_size_and_weight with digest auth":
    let client = newWalletRpcClient(password="password", username="monero")
    let estimateTxSizeAndWeightRequest = client.estimateTxSizeAndWeight(EstimateTxSizeAndWeightRequest(
      n_inputs: 1,
      n_outputs: 2,
      ring_size: 16,
      rct: true
    ))
    check estimateTxSizeAndWeightRequest.ok

# TODO: more tests
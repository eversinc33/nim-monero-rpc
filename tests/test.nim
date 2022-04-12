import unittest
import monerorpc, options

suite "test calls":
  echo "Running tests for monero-nim"
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
    
  # TODO: more tests
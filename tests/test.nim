import unittest
import monero_wallet_rpc, options

test "set_daemon":
  let client = newWalletRpcClient()
  let res = client.setDaemon(
    SetDaemonRequest(
      address: some("http://node.supportxmr.com:18081"),
      trusted: some(false)
    )
  )
  echo repr(res.data)
  echo $res.rawBody
  check res.ok

test "get_balance":
  let client = newWalletRpcClient()
  let res = client.getBalance(
    GetBalanceRequest()
  )
  echo repr(res.data)
  echo $res.rawBody
  echo res.data.balance
  check res.ok
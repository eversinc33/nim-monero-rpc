import unittest
import monero_wallet_rpc, structs

test "set_daemon":
  let client = newWalletRpcClient()
  let res = client.setDaemon(
    SetDaemonRequest()
  )
  echo repr(res.data)
  echo $res.rawBody
  check res.ok

test "get_balance":
  let client = newWalletRpcClient()
  let res = client.getBalance(
    GetBalanceRequest()
  )
  echo res.data.balance
  check res.ok
import unittest, httpclient
import monero_wallet_rpc

test "get_account_tags":
  let client = newWalletRpcClient()
  let res = client.getAccountTags()
  echo res.body
  check res.status == HttpCode(200)
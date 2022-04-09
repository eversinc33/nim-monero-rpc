import unittest, httpclient
import monero_nim

test "get_address":
  let client = newWalletRpcClient()
  let res = client.getAddress(0)
  echo res.body
  check res.status == HttpCode(200)

test "set_daemon":
  let client = newWalletRpcClient()
  let res = client.setDaemon("http://node.supportxmr.com:18081")
  echo res.body
  check res.status == HttpCode(200)

test "get_balance":
  let client = newWalletRpcClient()
  let res = client.getBalance(0)
  echo res.body
  check res.status == HttpCode(200)

test "get_address_index":
  let address = "42CLPuYc8Hd2ah16qdPC32c9MeN88YBCF4bp1BZHFRwqHdp7ea8gPJTTm7ZvCPt6KQ6Wx72tjNksRYz76ptF7wFNPUTEms3"
  let client = newWalletRpcClient()
  let res = client.getAddressIndex(address)
  echo res.body
  check res.status == HttpCode(200)

test "create_address":
  let client = newWalletRpcClient()
  let res = client.createAddress()
  echo res.body
  check res.status == HttpCode(200)

test "label_address":
  let client = newWalletRpcClient()
  let res = client.labelAddress(0, 0, "My First Address")
  echo res.body
  check res.status == HttpCode(200)

test "validate_address":
  let client = newWalletRpcClient()
  let res = client.validateAddress("42CLPuYc8Hd2ah16qdPC32c9MeN88YBCF4bp1BZHFRwqHdp7ea8gPJTTm7ZvCPt6KQ6Wx72tjNksRYz76ptF7wFNPUTEms3")
  echo res.body
  check res.status == HttpCode(200)

test "get_accounts":
  let client = newWalletRpcClient()
  let res = client.getAccounts()
  echo res.body
  check res.status == HttpCode(200)
  
test "create_account":
  let client = newWalletRpcClient()
  let res = client.createAccount()
  echo res.body
  check res.status == HttpCode(200)

test "label_account":
  let client = newWalletRpcClient()
  let res = client.labelAccount(0, "Relabeled")
  echo res.body
  check res.status == HttpCode(200)

test "get_account_tags":
  let client = newWalletRpcClient()
  let res = client.getAccountTags()
  echo res.body
  check res.status == HttpCode(200)
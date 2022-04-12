import std/sysrand, base64

proc randomString*(length: int = 32): string =
  result = encode(urandom(32))
type
    Daemon_SSL_Support* = enum
        Autodetect = "autodetect", Enabled = "enabled", Disabled = "disabled"

    TransferPriority* = enum
        Default = 0, Unimportant = 1, Normal = 2, Elevated = 3, Priority = 4 

    TransferRequestType* = enum
        All = "all", Available = "available", Unavailable = "unavailable"

    TransferType* = enum
        In = "in", Out = "out", Pending = "pending", Failed = "failed", Pool = "pool"

    KeyType* = enum
        Mnemonic = "mnemonic", ViewKey = "view_key"

    NetType* = enum
        Mainnet = "mainnet", Stagenet = "stagenet", Testnet = "testnet"

    UpdateCommand* = enum
        Check = "check", Download = "download"
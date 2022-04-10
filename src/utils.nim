type
    Daemon_SSL_Support* = enum
        Autodetect = "autodetect", Enabled = "enabled", Disabled = "disabled"

    TransferPriority* = enum
        Default = 0, Unimportant = 1, Normal = 2, Elevated = 3, Priority = 4 

    TransferType* = enum
        All = "all", Available = "available", Unavailable = "unavailable"

    KeyType* = enum
        Mnemonic = "mnemonic", ViewKey = "view_key"
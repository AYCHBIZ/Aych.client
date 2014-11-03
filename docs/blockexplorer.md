##Block explorer functionality

All functions support an optional parameter called `api_code`. It won't be listed with every function description.

####`get_block`
Get a single block based on a block index or hash. Returns a `Block` object.

Params: 
```
block_id : str - block index or hash
```

Usage:
```ruby
require 'blockchain'

block = Blockchain::get_block('000000000000000016f9a2c3e0f4c1245ff24856a79c34806969f5084f410680')
```

####`get_tx`
Get a single transaction based on a transaction index or hash. Returns a `Transaction` object.

Params:
```
tx_id : str - transaction index or hash
```

Usage:
```ruby
tx = Blockchain::get_tx('d4af240386cdacab4ca666d178afc88280b620ae308ae8d2585e9ab8fc664a94')
```

####`get_block_height`
Get an array of blocks at the specified height. Returns an array of `Block` objects.

Params:
```
height : int - block height
```

Usage:
```ruby
blocks = Blockchain::get_block_height(2570)
```

####`get_address`
Get a single address and its transactions. Returns an `Address` object.

Params:
```
address : str - address in the base58 or hash160 format
```

Usage:
```ruby
address = Blockchain::get_address('1HS9RLmKvJ7D1ZYgfPExJZQZA1DMU3DEVd')
```

####`get_unspent_outputs`
Get an array of unspent outputs for an address. Returns an array of `UnspentOutput` objects.

Params:
```
address : str - address in the base58 or hash160 format
```

Usage:
```ruby
outs = Blockchain::get_unspent_outputs('1HS9RLmKvJ7D1ZYgfPExJZQZA1DMU3DEVd')
```

####`get_latest_block`
Get the latest block on the main chain. Returns a `LatestBlock` object.

Usage:
```ruby
latest_block = Blockchain::get_latest_block()
```

####`get_unconfirmed_tx`
Get a list of currently unconfirmed transactions. Returns an array of `Transaction` objects.

Usage:
```ruby
txs = Blockchain::get_unconfirmed_tx()
```

####`get_blocks`
Get a list of blocks for a specific day or mining pool. Returns an array of `SimpleBlock` objects.

Params:
```
time : int - unix time in ms (optional)
pool_name : str - pool name (optional)
```
At least one parameter is required.

Usage:
```ruby
blocks = Blockchain::get_blocks(pool_name = 'Discus Fish')
```

####`get_inventory_data`
Get inventory data for recent blocks and addresses (up to 1 hour old). Returns an `InventoryData` object.

Params:
```
hash : str - tx or block hash
```

Usage:
```ruby
inv = Blockchain::get_inventory_data('d4af240386cdacab4ca666d178afc88280b620ae308ae8d2585e9ab8fc664a94')
```

Note regarding `Input` objects: if coinbase transaction, only `script` and `script_siq` will be populated.


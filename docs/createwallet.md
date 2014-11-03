##Create Wallet functionality

####`create_wallet`
Create a new Blockchain.info wallet. It can be created containing a pre-generated private key or will otherwise generate a new private key. Returns a `CreateWalletResponse` instance.

Params: 
```
password : str - password for the new wallet. At least 10 characters.
api_code : str - API code with the create wallets permission
priv : str - private key to add to the wallet (optional, keyword)
label : str - label for the first address in the wallet (optional, keyword)
email : str - email to associate with the new wallet (optional, keyword)
```

Usage:
```ruby
require 'blockchain'

wallet = Blockchain::create_wallet('1234password', '58ck39ajuiw', label: 'Test wallet')
```

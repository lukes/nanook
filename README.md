# NanoRpc

This is a Ruby library for managing a [nano currency](https://nano.org/) node, including making and receiving payments, using the [nano RPC protocol](https://github.com/nanocurrency/raiblocks/wiki/RPC-protocol). Nano is a fee-less, fast, environmentally-friendly cryptocurrency. It's awesome. See [https://nano.org/](https://nano.org/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nano_rpc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nano_rpc

# Getting Started

## Initializing

```ruby
nano = NanoRpc.new("http://localhost:7076")
```

## Basics

### Working with Wallets and Accounts

Create a wallet:

```ruby
nano.wallet.create
```

Create an account within a wallet:

```ruby
nano.wallet(wallet_id).account.create
```

List accounts within a wallet:

```ruby
nano.wallet(wallet_id).accounts.all
```

### Sending a payment

You send a payment from an account in a wallet.

```ruby
account = NanoRpc.new(host).wallet(wallet_id).account(account_id)
account.pay(to: recipient_account_id, amount: 0.2, id: unique_id)
```

The `id` needs to be unique per payment, and serves an important purpose; it allows you to make this call multiple times with the same `id` and be reassured that you will only ever send that nano payment once. From the [Nano RPC](https://github.com/nanocurrency/raiblocks/wiki/RPC-protocol#account-create):

> You can (and should) specify a unique id for each spend to provide idempotency. That means that if you [make the payment call] two times with the same id, the second request won't send any additional Nano.

The unit of the `amount` is NANO (which is currently technically 1Mnano &mdash; see [What are Nano's Units](https://nano.org/en/faq#what-are-nano-units-)).

Note, there may be a delay in receiving a response due to Proof of Work being done. From the [Nano RPC](https://github.com/nanocurrency/raiblocks/wiki/RPC-protocol#account-create):

> Proof of Work is precomputed for one transaction in the background. If it has been a while since your last transaction it will send instantly, the next one will need to wait for Proof of Work to be generated.

### Receiving a payment

The simplest way to receive a payment is:

```ruby
account = NanoRpc.new(host).wallet(wallet_id).account(account_id)
account.receive
```

The `receive` method when called without any arguments, as above, will receive the latest pending block for an account in a wallet. It will either return a RPC response containing the block if a payment was received, or `false` if there were no pending payments to receive.

You can also receive a specific pending block if you know it (you may have discovered it through calling `account.pending` for example):

```ruby
account = NanoRpc.new(host).wallet(wallet_id).account(account_id)
account.receive(block_id)
```

### All commands

#### Create wallet:

```ruby
nano.wallet.create
```

#### Working with a single wallet:

```ruby
wallet = nano.wallet(wallet_id)

wallet.destroy
wallet.export
wallet.locked  # Returns the RPC response
wallet.locked? # Returns boolean
wallet.contains(account_id)  # Returns the RPC response
wallet.contains?(account_id) # Returns boolean
```

#### Working with all accounts within a wallet:
```ruby
wallet.accounts.all
wallet.account.create
```
#### Working with a single account within a wallet:

```ruby
account = NanoRpc.new(host).wallet(wallet_id).account(account_id)

account.destroy
account.pay(to: recipient_account_id, amount: 0.2, id: unique_id)
account.receive                   # Receive the latest pending payment
account.receive(pending_block_id) # Receive a known pending payment
```

#### Working with any account (not necessarily in your wallet)

```ruby
nano = NanoRpc.new(host)

nano.account(account_id).history(count: 1000)
nano.account(account_id).key
nano.account(account_id).representative
```

## NanoRpc Metal

You can do any call listed in the [Nano RPC](https://github.com/nanocurrency/raiblocks/wiki/RPC-protocol) directly through the `nano.rpc` method. The first argument should match the `action` value in the RPC call, and then all remaining parameters are passed in as arguments.

```ruby
nano.rpc(:accounts_create, wallet: wallet_id, count: 2)
```

## Contributing

Bug reports and pull requests are welcome. Pull requests with passing tests are even better.

To run the test suite:

    bundle exec rspec spec

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## Buy Me a Nano Coffee

This library is totally free to use, but if you would like to send some Nano to [my wallet](https://www.nanode.co/account/xrb_3c3ek3k8135f6e8qtfy8eruk9q3yzmpebes7btzncccdest8ymzhjmnr196j), you can!

    xrb_3c3ek3k8135f6e8qtfy8eruk9q3yzmpebes7btzncccdest8ymzhjmnr196j





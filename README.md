# Nanook

This is a Ruby library for managing a [nano currency](https://nano.org/) node, including making and receiving payments, using the [nano RPC protocol](https://github.com/nanocurrency/raiblocks/wiki/RPC-protocol). Nano is a fee-less, fast, environmentally-friendly cryptocurrency. It's awesome. See [https://nano.org/](https://nano.org/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nanook'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nanook

# Getting Started

## Initializing

Nanook will by default connect to `http://localhost:7076`. If you're using Nanook from the nano node itself this will generally work fine.

```ruby
nanook = Nanook.new
```

To connect to another host instead:

```ruby
nanook = Nanook.new("http://example.com:7076")
```

## Basics

### Working with wallets and accounts

Create a wallet:

```ruby
Nanook.new.wallet.create
```

Create an account within a wallet:

```ruby
Nanook.new.wallet(wallet_id).accounts.create
```

List accounts within a wallet:

```ruby
Nanook.new.wallet(wallet_id).accounts.all
```

### Sending a payment

You send a payment from an account in a wallet.

```ruby
account = Nanook.new.wallet(wallet_id).account(account_id)
account.pay(to: recipient_account_id, amount: 0.2, id: unique_id)
```

The `id` can be any string and needs to be unique per payment. It serves an important purpose; it allows you to make this call multiple times with the same `id` and be reassured that you will only ever send that nano payment once. From the [Nano RPC](https://github.com/nanocurrency/raiblocks/wiki/RPC-protocol#account-create):

> You can (and should) specify a unique id for each spend to provide idempotency. That means that if you [make the payment call] two times with the same id, the second request won't send any additional Nano.

The unit of the `amount` is NANO (which is currently technically 1Mnano &mdash; see [What are Nano's Units](https://nano.org/en/faq#what-are-nano-units-)).

Note, there may be a delay in receiving a response due to Proof of Work being done. From the [Nano RPC](https://github.com/nanocurrency/raiblocks/wiki/RPC-protocol#account-create):

> Proof of Work is precomputed for one transaction in the background. If it has been a while since your last transaction it will send instantly, the next one will need to wait for Proof of Work to be generated.

### Receiving a payment

The simplest way to receive a payment is:

```ruby
account = Nanook.new.wallet(wallet_id).account(account_id)
account.receive
```

The `receive` method when called without any arguments, as above, will receive the latest pending payment for an account in a wallet. It will either return a RPC response containing the block if a payment was received, or `false` if there were no pending payments to receive.

You can also receive a specific pending block if you know it (you may have discovered it through calling `account.pending` for example):

```ruby
account = Nanook.new.wallet(wallet_id).account(account_id)
account.receive(block_id)
```

## All commands

### Wallets

#### Create wallet:

```ruby
Nanook.new.wallet.create
```

#### Working with a single wallet:

```ruby
wallet = Nanook.new.wallet(wallet_id)

wallet.export
wallet.locked?
wallet.unlock(password)
wallet.change_password(password)

wallet.accounts.create
wallet.accounts.all
wallet.contains?(account_id)

wallet.destroy
```
### Accounts

#### Create account:

```ruby
Nanook.new.wallet(wallet_id).account.create
```

#### Working with a single account:

```ruby
account = Nanook.new.wallet(wallet_id).account(account_id)

account.info
account.history
account.history(limit: 1)
account.key
account.representative

account.balance
account.pay(to: recipient_account_id, amount: 0.2, id: unique_id)
account.pending
account.pending(limit: 1)
account.receive
account.receive(pending_block_id)

account.destroy
```

#### Working with any account (not necessarily in your wallet):

```ruby
account = Nanook.new.account(account_id)

account.info
account.history
account.history(limit: 1)
account.key
account.representative

account.balance
account.pending
account.pending(limit: 1)
```

### Blocks

```ruby
block = Nanook.new.block(block_id)

block.info                        # Only works with verified blocks in the ledger
block.info(allow_unchecked: true) # Work for verified blocks AND unchecked synchronizing blocks
block.account
block.chain
block.chain(limit: 10)
block.history
block.history(limit: 10)
block.republish
block.republish(sources: 2)
block.republish(destinations: 2)
block.pending?
block.process
block.successors
block.successors(limit: 10)

block.generate_work
block.cancel_work
block.work_is_valid?(work_id)
```

### Managing your nano node

```ruby
node = Nanook.new.node

node.block_count
node.block_count_type
node.bootstrap_any
node.bootstrap(address: "::ffff:138.201.94.249", port: 7075)
node.frontier_count
node.peers
node.representatives
node.stop
node.version
```

## Nanook Metal

You can do any call listed in the [Nano RPC](https://github.com/nanocurrency/raiblocks/wiki/RPC-protocol) directly through the `rpc` method. The first argument should match the `action` of the RPC call, and then all remaining parameters are passed in as arguments.

E.g., the [accounts_create command](https://github.com/nanocurrency/raiblocks/wiki/RPC-protocol#accounts-create) can be called like this:

```ruby
Nano.new.rpc(:accounts_create, wallet: wallet_id, count: 2)
```

## Contributing

Bug reports and pull requests are welcome. Pull requests with passing tests are even better.

To run the test suite:

    bundle exec rspec spec

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## Buy me a nano coffee

This library is totally free to use, but feel free to send some nano [my way](https://www.nanode.co/account/xrb_3c3ek3k8135f6e8qtfy8eruk9q3yzmpebes7btzncccdest8ymzhjmnr196j) if you'd like to!

    xrb_3c3ek3k8135f6e8qtfy8eruk9q3yzmpebes7btzncccdest8ymzhjmnr196j

![alt xrb_3c3ek3k8135f6e8qtfy8eruk9q3yzmpebes7btzncccdest8ymzhjmnr196j](https://raw.githubusercontent.com/lukes/nanook/master/img/qr.png)




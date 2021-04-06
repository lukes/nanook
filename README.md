# Nanook

This is a Ruby library for managing a [nano currency](https://nano.org/) node, including making and receiving payments, using the [nano RPC protocol](https://docs.nano.org/commands/rpc-protocol). Nano is a fee-less, fast, environmentally-friendly cryptocurrency. It's awesome. See [https://nano.org](https://nano.org/).

[![Gem Version](https://badge.fury.io/rb/nanook.svg)](https://badge.fury.io/rb/nanook)
[![CircleCI](https://circleci.com/gh/lukes/nanook/tree/master.svg?style=shield)](https://circleci.com/gh/lukes/nanook/tree/master)


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

Nanook will by default connect to `http://localhost:7076`.

```ruby
nanook = Nanook.new
```

To connect to another host instead:

```ruby
nanook = Nanook.new("http://ip6-localhost:7076")
```

## Basics

### Working with wallets and accounts

Create a wallet:

```ruby
wallet = nanook.wallet.create
```

Create an account within a wallet:

```ruby
account = wallet.account.create
```

List accounts within a wallet:

```ruby
accounts = wallet.accounts
```

### Sending a payment

To send a payment from an account in a wallet:

```ruby
account = nanook.wallet(wallet_id).account(account_id)
account.pay(to: recipient_account_id, amount: 0.2, id: unique_id)
```

Or, a wallet:

```ruby
wallet = nanook.wallet(wallet_id)
wallet.pay(from: your_account_id, to: recipient_account_id, amount: 0.2, id: unique_id)
```

The `id` can be any string and needs to be unique per payment. It serves an important purpose; it allows you to make this call multiple times with the same `id` and be reassured that you will only ever send that nano payment once. From the [Nano RPC](https://docs.nano.org/commands/rpc-protocol/#send):

> You can (and should) specify a unique id for each spend to provide idempotency. That means that if you [make the payment call] two times with the same id, the second request won't send any additional Nano.

The unit of the `amount` is NANO (which is currently technically Mnano &mdash; see [What are Nano's Units](https://nano.org/en/faq#what-are-nano-units-)). You can pass an amount of raw instead by adding the `unit: :raw` argument:

```ruby
account.pay(to: recipient_account_id, amount: 999, unit: :raw, id: unique_id)
```

Note, there may be a delay in receiving a response due to Proof of Work being done. From the [Nano RPC](https://docs.nano.org/commands/rpc-protocol/#send):

> Proof of Work is precomputed for one transaction in the background. If it has been a while since your last transaction it will send instantly, the next one will need to wait for Proof of Work to be generated.

### Receiving a payment

The simplest way to receive a payment is:

```ruby
account = nanook.wallet(wallet_id).account(account_id)
account.receive

# or:

wallet = nanook.wallet(wallet_id)
wallet.receive(into: account_id)
```

The `receive` method when called as above will receive the latest pending payment for an account in a wallet. It will either return a block hash if a payment was received, or `false` if there were no pending payments to receive.

You can also receive a specific pending block if you know it (you may have discovered it through calling `account.pending` for example):

```ruby
account = nanook.wallet(wallet_id).account(account_id)
account.receive(block_id)

# or:

wallet = nanook.wallet(wallet_id)
wallet.receive(block_id, into: account_id)
```

## All commands

Below is a quick reference list of commands. See the [full Nanook documentation](https://lukes.github.io/nanook/2.5.1/) for a searchable detailed description of every class and method, what the arguments mean, and example responses (Tip: the classes are listed under the "**Nanook** < Object" item in the sidebar).

### Wallets

See the [full documentation for Nanook::Wallet](https://lukes.github.io/nanook/2.5.1/Nanook/Wallet.html) for a detailed description of each method and example responses.

#### Create wallet:

```ruby
nanook.wallet.create
```
#### Restoring a wallet from a seed

```ruby
nanook.wallet.restore(seed)
```
Optionally also restore the wallet's accounts:
```ruby
nanook.wallet.restore(seed, accounts: 2)
```

#### Working with a wallet:

```ruby
wallet = nanook.wallet(wallet_id)

wallet.balance
wallet.balance(account_break_down: true)
wallet.balance(unit: :raw)
wallet.pay(from: your_account_id, to: recipient_account_id, amount: 2, id: unique_id)
wallet.pay(from: your_account_id, to: recipient_account_id, amount: 2, id: unique_id, unit: :raw)
wallet.pending
wallet.pending(limit: 1)
wallet.pending(detailed: true)
wallet.pending(unit: :raw)
wallet.receive(into: account_id)
wallet.receive(pending_block_id, into: account_id)

wallet.account.create
wallet.account.create(5)
wallet.accounts
wallet.contains?(account_id)

wallet.default_representative
wallet.change_default_representative(new_representative)
wallet.info
wallet.info(unit: :raw)
wallet.export
wallet.lock
wallet.locked?
wallet.unlock(password)
wallet.change_password(password)

wallet.destroy
```
### Accounts

#### Create account:

```ruby
nanook.wallet(wallet_id).account.create
```

#### Create multiple accounts:

```ruby
nanook.wallet(wallet_id).account.create(5)
```

#### Working with any account:

These commands can be made for any account on the Nano network that is known by your node.

See the [full documentation for Nanook::Account](https://lukes.github.io/nanook/2.5.1/Nanook/Account.html) for a detailed description of each method and example responses.

```ruby
account = nanook.account(account_id)

account.balance
account.balance(unit: :raw)
account.pending
account.pending(limit: 1)
account.pending(detailed: true)
account.pending(unit: :raw)

account.exists?

account.info
account.info(detailed: true)
account.info(unit: :raw)
account.last_modified_at
account.ledger
account.ledger(limit: 10)
account.ledger(modified_since: Time.now)
account.ledger(unit: :raw)
account.history
account.history(limit: 1)
account.history(unit: :raw)
account.public_key
account.delegators
account.delegators(unit: :raw)
account.representative
account.weight
```

#### Working with an account created on the node:

For accounts that have been created on your node, you can initialize the wallet that the account was created in first, and then call additional methods.

As well as the following methods, all methods of [regular accounts](#working-with-any-account) can also be called.

See the [full documentation for Nanook::WalletAccount](https://lukes.github.io/nanook/2.5.1/Nanook/WalletAccount.html) for a detailed description of each method and example responses.

```ruby
wallet = nanook.wallet(wallet_id)
account = wallet.account(account_id)

account.pay(to: recipient_account_id, amount: 2, id: unique_id)
account.pay(to: recipient_account_id, amount: 2, id: unique_id, unit: :raw)
account.receive
account.receive(pending_block_id)
account.change_representative(new_representative)
account.destroy
```

### Blocks

See the [full documentation for Nanook::Block](https://lukes.github.io/nanook/2.5.1/Nanook/Block.html) for a detailed description of each method and example responses.

```ruby
block = nanook.block(block_id)

block.info                        # Verified blocks in the ledger
block.info(allow_unchecked: true) # Verified blocks AND unchecked synchronizing blocks
block.info(unit: :raw)
block.account
block.chain
block.chain(limit: 10)
block.chain(offset: 10)
block.confirm
block.confirmed_recently?
block.republish
block.republish(sources: 2)
block.republish(destinations: 2)
block.pending?
block.publish
block.successors
block.successors(limit: 10)
block.successors(offset: 10)

block.generate_work
block.generate_work(use_peers: true)
block.cancel_work
block.valid_work?(work_id)
```

### Managing your nano node

See the [full documentation for Nanook::Node](https://lukes.github.io/nanook/2.5.1/Nanook/Node.html) for a detailed description of each method and example responses.

```ruby
node = nanook.node

node.account_count
node.block_count
node.bootstrap(address: "::ffff:138.201.94.249", port: 7075)
node.bootstrap_any
node.bootstrap_lazy(block_id)
node.bootstrap_lazy(block_id, force: true)
node.bootstrap_status
node.confirmation_history
node.difficulty
node.difficulty(include_trend: true)
node.peers
node.representatives
node.representatives(unit: :raw)
node.representatives_online
node.synchronizing_blocks
node.synchronizing_blocks(limit: 1)
node.sync_progress
node.version

node.stop
```

### Work peers

```ruby
work_peers = nanook.work_peers

work_peers.add(address: "::ffff:172.17.0.1:7076", port: 7076)
work_peers.clear
work_peers.list
```

### Keys

#### Create private public key pair:

```ruby
nanook.key.generate
nanook.key.generate(seed: seed, index: 0)
```

#### Working with a single key

```ruby
key = nanook.key(private_key)

key.info
```

## Nanook Metal

You can do any call listed in the [Nano RPC](https://docs.nano.org/commands/rpc-protocol) directly through the `rpc` method. The first argument should match the `action` of the RPC call, and then all remaining parameters are passed in as arguments.

E.g., the [accounts_create command](https://docs.nano.org/commands/rpc-protocol/#accounts_create) can be called like this:

```ruby
nanook.rpc.call(:accounts_create, wallet: wallet_id, count: 2)
```

## Contributing

Bug reports and pull requests are welcome. Pull requests with passing tests are even better.

To run the test suite:

    bundle exec rspec spec

To update the yard documentation:

    bundle exec rake yard

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Buy me a nano coffee

This library is totally free to use, but feel free to send some nano [my way](https://www.nanode.co/account/nano_3c3ek3k8135f6e8qtfy8eruk9q3yzmpebes7btzncccdest8ymzhjmnr196j) if you'd like to!

    nano_3c3ek3k8135f6e8qtfy8eruk9q3yzmpebes7btzncccdest8ymzhjmnr196j

![alt nano_3c3ek3k8135f6e8qtfy8eruk9q3yzmpebes7btzncccdest8ymzhjmnr196j](https://raw.githubusercontent.com/lukes/nanook/master/img/qr.png)




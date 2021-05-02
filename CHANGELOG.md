# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 3.1.0

### Added

- `Block#next`.
- `Block#descendants` aliases `Block#successors`

### Changed

- `Block.chain` and `Block.successors` no longer return the Block itself in the response.

## 3.0.1

### Fixed

- Fix `Block#type` being `nil` when RPC doesn't return a `subtype`.

## 3.0.0

### Removed

- `Nanook::Block#block_count_by_type` Removed, as the RPC no longer supports this command.
- `Nanook::Block#history` Removed, as the RPC command is deprecated.
- `Nanook::Block#publish` Removed, as the RPC command expects more data than what we instantiate within `Nanook::Block`.
- Removed all RPC calls that are not recommended for production:
  - `Nanook::Node#bootstrap_status`.
  - `Nanook::Node#confirmation_history`.
  - `Nanook::Node#confirmed_recently?`.
- `Nanook::Key` Replaced by `Nanook::PrivateKey`.
- `Nanook::Account#info` No longer accepts `detailed:` argument.
- `Nanook::Node#synced?` As this was deprecated for removal in v3.0.

### Added

- Added missing `Nanook::WalletAccount#block_count` delegate.
- Added `Nanook#network_telemetry`.
- Added `Nanook::Rpc#test`.
- Added `Nanook::WalletAccount#work`.
- Added `Nanook::WalletAccount#set_work`.
- Added `Nanook::Account#blocks`.
- Added `Nanook::Account#delegators_count`.
- Added `Nanook::Account#open_block`.
- Added `Nanook::Node#change_receive_minimum`.
- Added `Nanook::Node#confirmation_quorum`.
- Added `Nanook::Node#keepalive`.
- Added `Nanook::Node#receive_minimum`.
- Added `Nanook::Node#search_pending`.
- Added `Nanook::Wallet#history`.
- Added `Nanook::Wallet#exists?`.
- Added `Nanook::Wallet#ledger`.
- Added `Nanook::Wallet#move_accounts`.
- Added `Nanook::Wallet#remove_account`.
- Added `Nanook::Wallet#republish_blocks`.
- Added `Nanook::Wallet#search_pending`.
- Added `Nanook::Wallet#work`.
- Added `Nanook::Block#account`.
- Added `Nanook::Block#amount`.
- Added `Nanook::Block#balance`.
- Added `Nanook::Block#change?`.
- Added `Nanook::Block#confirmed?`.
- Added `Nanook::Block#epoch?`.
- Added `Nanook::Block#exists?`.
- Added `Nanook::Block#height`.
- Added `Nanook::Block#open?`.
- Added `Nanook::Block#previous`.
- Added `Nanook::Block#receive?`.
- Added `Nanook::Block#representative`.
- Added `Nanook::Block#send?`.
- Added `Nanook::Block#signature`.
- Added `Nanook::Block#timestamp`.
- Added `Nanook::Block#type`.
- Added `Nanook::Block#unconfirmed?`.
- Added `Nanook::Block#work`.
- Added `Nanook::PrivateKey` with methods `#create`, `#account` and `#public_key`.
- Added `Nanook::PublicKey` with method `#account`.
- Added equality testing methods `#==`, `#eql?` and `#hash` for:
    - `Nanook::Account`
    - `Nanook::Block`
    - `Nanook::PrivateKey`
    - `Nanook::PublicKey`
    - `Nanook::Wallet`
    - `Nanook::WalletAccount`

### Changed

- New error classes: `Nanook::ConnectionError`, `NanoUnitError`, `NodeRpcError` and `NodeRpcConfigurationError`.
- `Nanook::Wallet#default_representative` returns a `Nanook::Account`.
- `Nanook::Wallet#change_representative` returns a `Nanook::Account`.
- `Nanook::Wallet#unlock` can be passed no argument (`password` will be `nil`).
- `Nanook::Wallet#info` returns data from `wallet_info` RPC.
- `Nanook::Block#is_valid_work?` renamed to `#valid_work?`.
- `Nanook::Block#republish` returns an Array of `Nanook::Block`s.
- `Nanook::Block#chain` returns an Array of `Nanook::Block`s.
- `Nanook::Block#successors` returns an Array of `Nanook::Block`s.
- `Nanook::Block#info`:
  - returns balances in nano, and can optionally be passed `unit: :raw` argument.
  - returns account values as `Nanook::Account` and block values as `Nanook::Block`.
- `Nanook::Node#peers` returns details as a `Hash` keyed by `Nanook::Account`.
- `Nanook::Account#pending` returns source as `Nanook::Account` and block as `Nanook::Block` when `detailed: true`.
- `Nanook::Account#representative` returns a `Nanook::Account`.
- `Nanook::Account#delegators` returns accounts as `Nanook::Account`s.
- `Nanook::Account#history` returns accounts as `Nanook::Account` and blocks as `Nanook::Block`.
- `Nanook::Account#ledger` returns accounts as `Nanook::Account` and blocks as `Nanook::Block`.
- `Nanook::Account#public_key` returns a `Nanook::PublicKey`.
- `Nanook::Account#weight` accepts an optional `unit:` argment.
- `Nanook::Account#info`:
     - returns the `frontier`, `open_block`, `representative_block` values as `Nanook::Block`s.
     - returns the `representative` as a `Nanook::Account`.
     - `modified_timestamp` key renamed to `last_modified_at` and value is a `Time` in UTC.
- `Nanook::Key` has become `Nanook::PrivateKey`, `#generate` has been renamed `#create` and returns a `Nanook::PrivateKey`.

### Fixed

- A number of errors when node is still bootstrapping and is missing accounts from the ledger.
- `Nanook::Node#representatives_online` accessing representative list as a `Hash` after RPC change.

## 2.5.1

### Fixed

- undefined method 'new' for `BigDecimal:Class` (thank you @MihaiVoinea)

## 2.5.0

### Added

- New `Nanook::Node#bootstrap_lazy` method.
- New `Nanook::Node#bootstrap_status` method.
- New `Nanook::Node#difficulty` method.
- New `Nanook::Node#uptime` method.
- New `Nanook::Wallet#lock` method.

### Changed

- `Nanook::Node#chain` now takes optional `offset` argument.
- `Nanook::Node#successors` now takes optional `offset` argument.
- `Nanook::Node#successors` now aliased as `Nanook::Node#ancestors`
- Updated docs to use `nano_` prefixed addresses.

## 2.4.0

### Added

- New `Nanook::Node#confirmation_history` method.
- New `Nanook::Block#confirm` method.
- New `Nanook::Block#confirmed_recently?` method.

### Changed

- `Nanook::Block#generate_work` now can take optional `use_peers` argument.

## 2.3.0

### Added

- New `Nanook::Wallet#default_representative` method.
- New `Nanook::Wallet#change_default_representative` method.
- New `Nanook::Wallet#info` method.

## 2.2.0

### Added

- New `Nanook::Account#block_count` method returns number of blocks in ledger for an account.
- `Nanook::Node#block_count_type` is now an alias to the preferred `#block_count_by_type`
  method.
- new `Nanook::Node#representatives_online` method.
- `Nanook::Node#synchronizing_blocks` aliased by `#unchecked`, for people familiar with
  what the RPC calls it.
- `Nanook::Node#version` now an aliased by `#info`
  method.
- `Nanook::WalletAccount#exists?` now aliased by `#open?`

### Removed

- `Nanook::WalletAccount#account_id` Removed, as there was already an `id` method that returned this.
- `Nanook::WalletAccount#wallet_id` Removed, as the `WalletAccount` object should be considered a kind of Account.

### Changed

- `Nanook::Account#delegators` now takes `unit` argument.
- `Nanook::Account#ledger` now takes `unit` and `modified_since` arguments.
- `Nanook::Node#representatives` now takes `unit` argument.
- `Nanook::Node#synced?` is deprecated with a `warn`. Nodes never seem to reach 100%
  synchronized, so this method is useless.
- `Nanook::Rpc::DEFAULT_TIMEOUT` reduced from 500 to 60.

## 2.1.0

### Changed

- Payment methods no longer check that recipient account has an open block, as this prevents
  funds being sent to accounts about to be opened.
- Payment methods now check the account id of the recipient is valid, raises ArgumentError if not.
- Payment methods now return a Nanook::Error if the RPC returns an error when trying to pay, instead of a String.

## 2.0.0

### Added

- User can define `Nanook::UNIT = :raw` to set the default unit to `:raw` instead of `:nano`.
- `Nanook::Wallet#restore` to create a wallet, change its seed and create x number of accounts.
- `Nanook::WalletAccount#create` takes an optional argument to signal
  how many accounts to create.
- New `Nanook::WalletAccount#change_representative` method to change an
  account's representative.
- New `Nanook::Node#account_count` method to return number of known accounts in ledger.
- New `Nanook::Node#synchronizing_blocks` method to return information about "unchecked" synchronizing blocks.
- New `Nanook::Account#last_modified_at` method.
- Added ruby version requirement >= 2.0 to gemspec.

### Changed

- `Nanook::Rpc#inspect` displays full hostname with scheme and port.
- `Nanook::Account#new` `account` param is now required.
- `Nanook::Account#info` now also returns the `id` of the account.
- `Nanook::Account#history` now returns `amount` in NANO by default, takes `unit: :raw` argument to return in raw.
- `Nanook::Account#info` now returns `balance` and `pending` in NANO by default, takes `unit: :raw` argument to return in raw.
- `Nanook::Account#exists?` now checks for open block.
- `Nanook::Account#pending` now takes additional arguments `detailed:` and `unit:`.
- `Nanook::Block#account` now returns a `Nanook::Account` instance.
- `Nanook::Block#info` now also returns the `id` of the block.
- `Nanook::Wallet#accounts` now returns `Nanook::WalletAccount` instances.
- `Nanook::Wallet#create` now returns a `Nanook::Wallet` instance.
- `Nanook::Wallet#pending` now takes additional arguments `detailed:` and `unit:`.
- `Nanook::Wallet#seed` alias method of `#id`.
- `Nanook::WalletAccount#create` now returns `Nanook::WalletAccount` instances.
- Changed documentation generating tool from rdoc to yard.

### Fixed

- Missing `Nanook#rpc` accessor.
- `Nanook::Block#publish` can return false when publish fails.
- `Nanook::Block#info` correctly handles `allow_unchecked: true` errors.

## 1.0.1

### Fixed

- `Nanook::Wallet#balance(account_break_down: true)` always returning 0 `pending` balance.

### Changed

- Use `block.publish` in `README.md` and not the alias `block.process`.

## 1.0.0

### Added

- Added this CHANGELOG.md
- All classes have an `inspect` method
- New `id` method for `Nanook::Account`, `Nanook::Block`, `Nanook::Key` and `Nanook::Wallet` classes
- `Nanook::WalletAccount` class has an `account_id` and `wallet_id` method

### Changed

- Balance checking methods will now return the balance in NANO by default.
  They take an argument `unit:` which can be set to `:raw` to have the
  balance return in raw units.
- All pay methods continue to take NANO as the default unit, but can now
  also take an argument `unit:` which can be set to `:raw` to have the
  `amount` argument be treated as being in raw instead of NANO.

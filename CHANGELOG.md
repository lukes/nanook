# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Nanook::WalletAccount#create` takes an optional argument to signal
  how many accounts to create.
- New `Nanook::WalletAccount#change_representative` method to change an
  account's representative.
- Added ruby version requirement >= 2.0 to gemspec.

### Changed
- `Nanook::Rpc#inspect` displays full hostname with scheme and port.

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
